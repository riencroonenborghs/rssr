class AddTitleToRssFeeds < ActiveRecord::Migration[8.1]
  def change
    add_column :rss_feeds, :title, :string
  end
end
