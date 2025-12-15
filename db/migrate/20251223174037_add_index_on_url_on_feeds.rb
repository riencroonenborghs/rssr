class AddIndexOnUrlOnFeeds < ActiveRecord::Migration[7.2]
  def change
    remove_index :feeds, :url
    add_index :feeds, :url, unique: true
  end
end
