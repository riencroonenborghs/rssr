class RenameNameToTitleInFeeds < ActiveRecord::Migration[7.2]
  def change
    rename_column :feeds, :name, :title
  end
end
