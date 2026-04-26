json.reports @reports do |report|
  json.id report.id
  json.keywords report.keywords
  json.last_generated_at report.last_generated_at
end

json.meta do
  json.current_page @reports.current_page
  json.total_pages @reports.total_pages
  json.total_count @reports.total_count
end
