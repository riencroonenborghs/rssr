class CreateRssFeeds < ActiveRecord::Migration[8.1]
  def change
    create_table :rss_feeds do |t|
      t.string :url, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_fetched_at
      t.string :error

      t.timestamps
    end
    add_index :rss_feeds, :url, unique: true
  end
end
