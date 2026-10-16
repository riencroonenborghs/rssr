json.summary @result.summary
json.total @result.total
json.entries @result.entries do |entry|
  json.id entry.id
  json.title entry.title
  json.url entry.url
  json.published_at entry.published_at || entry.created_at
  json.feed do
    json.id entry.rss_feed.id
    json.title entry.rss_feed.display_title
  end
end
