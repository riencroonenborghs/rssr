class AddHideFromMainPageToSubsription < ActiveRecord::Migration[6.0]
  def change
    add_column :subscriptions, :hide_from_main_page, :boolean, default: false
  end
end
