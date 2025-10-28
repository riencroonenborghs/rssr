json.page @page
json.totalPages @subscriptions.total_pages
json.subscriptions do
  json.array! @subscriptions do |subscription|
    json.id subscription.id
    json.active subscription.active
    json.createdAt subscription.created_at.to_formatted_s(:long)
    json.lastFetchedAt subscription.feed.refresh_at.to_formatted_s(:long)
    json.entriesCount @feed_counts[subscription.feed_id]
    json.error subscription.feed.error

    json.feed do
      json.id subscription.feed.id
      json.name subscription.feed.name
    end
  end
end
