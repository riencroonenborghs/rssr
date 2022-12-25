class AddFeedTypeToFeeds < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :feed_type, :string, default: "rss"
  end
end
