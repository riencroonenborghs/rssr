json.feeds do
  json.array! @feeds do |feed|
    json.id feed.id
    json.name feed.name
    json.numberOfEntries @feed_counts[feed.id]
  end
end
