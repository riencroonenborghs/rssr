json.feeds @feeds do |feed|
  json.id feed.id
  json.title feed.title
  json.url feed.url
  json.count @entry_count_by_feed_id[feed.id] || 0
end
