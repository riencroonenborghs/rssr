class AddIndexOnFilters < ActiveRecord::Migration[6.0]
  def change
    add_index :filters, [:value, :user_id], name: "filter_val_usr_type"
  end
end
