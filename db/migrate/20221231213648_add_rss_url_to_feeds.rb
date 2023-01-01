class AddRssUrlToFeeds < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :rss_url, :string
  end
end
