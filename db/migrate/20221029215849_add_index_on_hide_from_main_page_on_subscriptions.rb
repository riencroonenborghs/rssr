class AddIndexOnHideFromMainPageOnSubscriptions < ActiveRecord::Migration[6.0]
  def change
    remove_index :subscriptions, name: "sub_usr_fd_actv"
    add_index :subscriptions, :hide_from_main_page
    add_index :subscriptions, [:user_id, :feed_id, :active, :hide_from_main_page], name: "sub_u_f_a_hfmp"
  end
end
