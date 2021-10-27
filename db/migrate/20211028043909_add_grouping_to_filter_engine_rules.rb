class AddGroupingToFilterEngineRules < ActiveRecord::Migration[6.0]
  def change
    add_column :filter_engine_rules, :group_id, :integer, null: false
  end
end
