class ChangeFilterComparisons < ActiveRecord::Migration[6.0]
  def change
    Filter.all.each do |filter|
      case filter.comparison
      when "eq"
        filter.comparison = "includes"
      when "ne"
        filter.comparison = "excludes"
      end
      filter.save!
    end
  end
end
