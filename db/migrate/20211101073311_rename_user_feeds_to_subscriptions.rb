class RenameUserFeedsToSubscriptions < ActiveRecord::Migration[6.0]
  def change
    rename_table :user_feeds, :subscriptions
  end
end
