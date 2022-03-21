class Filter < ApplicationRecord
  VALID_COMPARISONS = %w[eq ne lt lte gt gte].freeze

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: :user_id }
  validates :comparison, inclusion: { in: VALID_COMPARISONS }

  def chain(scope)
    value.upcase.split(",").map do |part|
      scope = scope.where("upper(entries.title) #{sql_comparison} ?", "%#{part}%")
    end

    scope
  end

  def human_readable
    "the title #{human_readable_comparison} #{value.upcase}"
  end

  private

  def sql_comparison
    @sql_comparison ||= comparison == "ne" ? "not like" : "like"
  end

  def human_readable_comparison
    comparison == "ne" ? "does not contain" : "contains"
  end
end
