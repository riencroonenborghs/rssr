json.page @page
json.totalPages @filters.total_pages
json.filters do
  json.array! @filters do |filter|
    json.id filter.id
    json.comparison filter.comparison
    json.value filter.value
  end
end
