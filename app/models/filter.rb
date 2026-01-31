# frozen_string_literal: true

# == Schema Information
#
# Table name: filters
#
#  id         :integer          not null, primary key
#  comparison :string           default("eq"), not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_filters_on_user_id  (user_id)
#  uniq_filter_val_usr_type  (value,user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Filter < ApplicationRecord
  INCLUDES_FILTER = "includes"
  TAGGED_FILTER = "tagged"

  VALID_COMPARISONS = [
    INCLUDES_FILTER,
    TAGGED_FILTER
  ].freeze

  HUMAN_READABLE = {
    INCLUDES_FILTER => "contains",
    TAGGED_FILTER => "tagged with"
  }.freeze

  FORM = {
    INCLUDES_FILTER => "contains",
    TAGGED_FILTER => "tagged with"
  }.freeze

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: :user_id }
  validates :comparison, inclusion: { in: VALID_COMPARISONS }

  def human_readable
    "the title #{human_readable_comparison} #{value.upcase}"
  end

  def human_readable_comparison
    HUMAN_READABLE[comparison]
  end
end
