json.subscriptions @subscriptions do |sub|
  json.id sub.id
  json.feed do
    json.id sub.feed.id
    json.title sub.feed.title
    json.url sub.feed.url
  end
end
