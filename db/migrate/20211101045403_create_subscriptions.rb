class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feed, null: false, foreign_key: true

      t.timestamps
    end
    add_index :subscriptions, [:user_id, :feed_id], unique: true

    Feed.all.each do |feed|
      Subscription.create!(user_id: feed.user_id, feed_id: feed.id)
    end

    remove_column :feeds, :user_id
  end
end
