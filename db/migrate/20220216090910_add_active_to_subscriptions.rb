class AddActiveToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :active, :boolean, null: false, default: true
  end
end
