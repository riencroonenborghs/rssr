json.filters @filters do |filter|
  json.id filter.id
  json.comparison filter.comparison
  json.value filter.value
end

json.meta do
  json.current_page @filters.current_page
  json.total_pages @filters.total_pages
  json.total_count @filters.total_count
end
