# frozen_string_literal: true

# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  keywords          :string           not null
#  last_generated_at :datetime
#  report_type       :integer          default("daily"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer          not null
#
# Indexes
#
#  index_reports_on_user_id                  (user_id)
#  index_reports_on_user_id_and_report_type  (user_id,report_type)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Report < ApplicationRecord
  belongs_to :user

  serialize :keywords, coder: JSON

  validates :keywords, presence: true

  has_many :generated_reports, dependent: :destroy

  enum report_type: {
    daily: 0,
    weekly: 1
  }
end
