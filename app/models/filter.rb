class Filter < ApplicationRecord
  VALID_COMPARISONS = %w[includes excludes matches mismatches].freeze

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: :user_id }
  validates :comparison, inclusion: { in: VALID_COMPARISONS }

  def human_readable
    "the title #{human_readable_comparison} #{value.upcase}"
  end

  private

  def human_readable_comparison
    case comparison
    when "includes"
      "contains"
    when "excludes"
      "does not contain"
    when "matches"
      "matches"
    when "mismatches"
      "does not match"
    end
  end
end
