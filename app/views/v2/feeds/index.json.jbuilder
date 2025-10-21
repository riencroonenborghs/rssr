json.feeds do
  json.array! @feeds do |feed|
    json.id feed.id
    json.name feed.name
    json.numberOfEntries feed.entries.count
  end
end
