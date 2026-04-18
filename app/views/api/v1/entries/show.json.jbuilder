json.feed do
  json.id @feed.id
  json.title @feed.title
  json.url @feed.url
end

json.entry do
  json.id @entry.id
  json.title @entry.title
  json.description @entry.description
  json.link @entry.link
  json.image @entry.image
  json.published_at @entry.published_at
  json.viewed @viewed
  json.bookmarked @bookmarks
  json.tags @tags do |tag|
    json.id tag.id
    json.name tag.name
  end
end
