require 'twitter'

USERNAME = 'ochremusic'
MAX_TWEET_AGE_MONTHS = 6
DELETE_MEDIA_TWEETS = false
START_FROM_ID = nil
SAFE_TWEETS = [
  849169274409189376
]

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

max_age_days = Date.today - (Date.today << MAX_TWEET_AGE_MONTHS)
max_age_secs = max_age_days.to_i * 24 * 60 * 60

begin
  id = START_FROM_ID || client.user_timeline(USERNAME).first.id
  timeline = []
  stale_tweets = []
  count = 200

  puts 'Fetching all tweets...'

  loop do
    tweets =
      client.user_timeline(
        USERNAME,
        count: count,
        max_id: id,
        tweet_mode: 'extended'
      )

    tweets.each do |tweet|
      break if tweet.nil?

      next unless tweet.created_at < Time.now - max_age_secs &&
                  !SAFE_TWEETS.include?(tweet.id) &&
                  (!tweet.media? || DELETE_MEDIA_TWEETS)

      stale_tweets << tweet
    end

    timeline.concat tweets
    break if id == tweets.last.id ||
             tweets.count.nil?

    id = tweets.last.id
  end

  # Delete stale non-media tweets.
  # stale_tweets.each do |tw|
  #   client.destroy_status(tw.id)
  # end

  puts "### STATS for @#{USERNAME} ###"
  puts 'Tweet count:' + timeline.count.to_s

  non_retweets = timeline.reject(&:retweet?)
  mean_fav = (non_retweets.sum(&:favorite_count) / non_retweets.count.to_f).round
  median_fav = non_retweets.sort_by(&:favorite_count)[non_retweets.count / 2].favorite_count
  max_fav = non_retweets.sort_by(&:favorite_count).last.favorite_count
  puts "Fav counts | Mean: #{mean_fav} | Median: #{median_fav} | Max: #{max_fav}"

  mean_rt = (non_retweets.sum(&:retweet_count) / non_retweets.count.to_f).round
  median_rt = non_retweets.sort_by(&:retweet_count)[non_retweets.count / 2].favorite_count
  max_rt = non_retweets.sort_by(&:retweet_count).last.retweet_count
  puts "Retweet counts | Mean: #{mean_rt} | Median: #{median_rt} | Max: #{max_rt}"

  puts 'Stale tweets:' + stale_tweets.count.to_s
rescue StandardError => error
  warn "Error: #{error.message}"
end
