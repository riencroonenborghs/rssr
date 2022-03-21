class RenameRulesToFilters < ActiveRecord::Migration[6.0]
  def change
    rename_table :filter_engine_rules, :filters
  end
end
