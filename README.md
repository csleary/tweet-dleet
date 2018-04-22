Just uncomment the delete block at the bottom to actually delete your oldest, crappest tweates and replies.

The rate limiting will only permit the return of ~3200 tweets, so multiple passes might be necessary.

By default this script will skip media tweets (anything with video, images, but not links/cards). Set the `DELETE_MEDIA_TWEETS` constant to `true` if you'd rather nuke old media posts as well. Given that these tend to be more useful as part of a tweet archive (less contemporaneously relevant), you may find they're worth keeping.
