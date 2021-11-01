class RenameTitleToNameInFeeds < ActiveRecord::Migration[6.0]
  def change
    rename_column :feeds, :title, :name
  end
end
