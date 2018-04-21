require 'twitter'

USERNAME = 'ochremusic'
MAX_TWEET_AGE_MONTHS = 6

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

max_age_days = Date.today - (Date.today << MAX_TWEET_AGE_MONTHS)
max_age_secs = max_age_days.to_i * 24 * 60 * 60

id = client.user_timeline(USERNAME).first.id
timeline = []
stale_tweets = []
count = 200

puts 'Fetching all tweets...'

# TODO make array of safe tweet IDs that should be kept (keybase etc.).

loop do
  tweets = client.user_timeline(USERNAME, count: count, max_id: id)
  tweets.each do |tw|
    stale_tweets << tw if tw.created_at < Time.now - max_age_secs == true && !tw.media?
  end
  timeline.concat tweets
  id = tweets.last.id
  break if tweets.count < count
end

# Delete stale non-media tweets.
# stale_tweets.each do |tw|
#   client.destroy_status(tw.id)
# end

puts 'Tweet count:' + timeline.count.to_s
puts 'Stale tweets:' + stale_tweets.count.to_s
