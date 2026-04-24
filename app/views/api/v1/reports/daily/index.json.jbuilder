json.reports @daily_reports do |generated_report|
  json.id generated_report.id
  json.created_at generated_report.created_at
  json.report do
    json.id generated_report.report.id
    json.keywords generated_report.report.keywords
  end
end
