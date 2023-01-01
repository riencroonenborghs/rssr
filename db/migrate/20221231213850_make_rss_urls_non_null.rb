class MakeRssUrlsNonNull < ActiveRecord::Migration[6.0]
  def change
    change_column :feeds, :rss_url, :string, null: false
  end
end
