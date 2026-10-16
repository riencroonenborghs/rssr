json.id subscription.id
json.feed do
  json.partial! "api/feeds/feed", feed: subscription.rss_feed
  json.error subscription.rss_feed.error
end
