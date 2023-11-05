# frozen_string_literal: true

class Filter < ApplicationRecord
  VALID_COMPARISONS = %w[includes excludes matches mismatches].freeze
  HUMAN_READABLES = {
    "includes" => "contains",
    "excludes" => "does not contain",
    "matches" => "matches",
    "mismatches" => "does not match"
  }.freeze

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: :user_id }
  validates :comparison, inclusion: { in: VALID_COMPARISONS }

  def human_readable
    "the title #{human_readable_comparison} #{value.upcase}"
  end

  def human_readable_comparison
    HUMAN_READABLES[comparison]
  end
end
