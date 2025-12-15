class RemoveRssUrlFromFeeds < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE feeds set url = rss_url;"

    remove_column :feeds, :rss_url
  end

  def down
    add_columns :feeds, :url, :string, null: false

    execute "UPDATE feeds set rss_url = url;"
  end
end
