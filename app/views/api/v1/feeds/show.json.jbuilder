json.feed do
  json.id @feed.id
  json.title @feed.title
  json.url @feed.url
end

json.entries @entries do |entry|
  json.id entry.id
  json.title entry.title
  json.description entry.description
  json.link entry.link
  json.image entry.image
  json.published_at entry.published_at
  json.viewed @viewed_entries.key?(entry.id)
  json.bookmarked @bookmarks.key?(entry.id)
  json.bookmark_id @bookmarks[entry.id]&.id
  json.tags (@tags_by_entry[entry.id] || []) do |tag|
    json.id tag.id
    json.name tag.name
  end
end

json.meta do
  json.current_page @entries.current_page
  json.total_pages @entries.total_pages
  json.total_count @entries.total_count
end
