class CleanUpSubscriptions < ActiveRecord::Migration[7.2]
  def change
    remove_column :subscriptions, :hide_from_main_page
  end
end
