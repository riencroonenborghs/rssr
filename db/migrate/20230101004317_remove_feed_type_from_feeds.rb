class RemoveFeedTypeFromFeeds < ActiveRecord::Migration[6.0]
  def change
    remove_column :feeds, :feed_type
  end
end
