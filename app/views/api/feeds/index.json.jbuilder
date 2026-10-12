json.array! @feeds do |feed|
  json.partial! "api/feeds/feed", feed: feed
  json.unread_count @unread_counts.fetch(feed.id, 0)
end
