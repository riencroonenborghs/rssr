class RemoveTypeFromFilters < ActiveRecord::Migration[6.0]
  def change
    remove_column :filters, :type
  end
end
