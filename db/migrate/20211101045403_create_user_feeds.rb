class CreateUserFeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :user_feeds do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feed, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_feeds, [:user_id, :feed_id], unique: true

    Feed.all.each do |feed|
      UserFeed.create!(user_id: feed.user_id, feed_id: feed.id)
    end

    remove_column :feeds, :user_id
  end
end
