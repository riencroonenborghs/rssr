# frozen_string_literal: true

# == Schema Information
#
# Table name: generated_reports
#
#  id         :integer          not null, primary key
#  prompt     :string           not null
#  summary    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  report_id  :integer          not null
#
# Indexes
#
#  index_generated_reports_on_report_id  (report_id)
#
# Foreign Keys
#
#  report_id  (report_id => reports.id)
#
class GeneratedReport < ApplicationRecord
  belongs_to :report

  validates :summary, presence: true
end
