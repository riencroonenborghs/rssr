json.report do
  json.id @daily_report.id
  json.summary @daily_report.summary
  json.created_at @daily_report.created_at
  json.report do
    json.id @daily_report.report.id
    json.keywords @daily_report.report.keywords
  end
end
