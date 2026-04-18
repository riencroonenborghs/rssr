json.feeds @feeds do |feed|
  json.id feed.id
  json.title feed.title
  json.url feed.url
end
