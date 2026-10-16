json.id subscription.id
json.feed do
  json.partial! "api/feeds/feed", feed: subscription.rss_feed
  json.error subscription.rss_feed.error
  json.last_fetched_at subscription.rss_feed.last_fetched_at
end
