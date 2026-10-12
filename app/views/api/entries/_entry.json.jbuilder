json.id entry.id
json.title entry.title
json.published_at entry.published_at || entry.created_at
json.image_url entry.image_url
json.read entry_read?(entry)
json.bookmarked entry_bookmarked?(entry)
json.feed do
  json.id entry.rss_feed.id
  json.title entry.rss_feed.display_title
end
