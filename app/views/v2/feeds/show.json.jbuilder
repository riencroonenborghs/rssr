json.page @page
json.totalPages @entries.total_pages
json.feed do
  json.id @feed.id
  json.name @feed.name
end
json.entries do
  json.array! @entries do |entry|
    json.id entry.id
    json.title entry.title
    json.link entry.link
    json.description entry.description
    json.publishedAt entry.published_at.to_formatted_s(:long)
    json.tags @subscriptions_by_feed_id[entry.feed_id]&.tag_list || []
    json.image entry.image
    json.viewed @viewed_ids.include?(entry.id)
    json.bookmarked @bookmarked_ids.include?(entry.id)

    json.feed do
      json.id @feed.id
      json.name @feed.name
    end
  end
end
