class RemoteGroupIdFromRules < ActiveRecord::Migration[6.0]
  def change
    remove_column :filter_engine_rules, :group_id
  end
end
