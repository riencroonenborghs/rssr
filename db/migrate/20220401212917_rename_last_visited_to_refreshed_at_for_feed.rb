class RenameLastVisitedToRefreshedAtForFeed < ActiveRecord::Migration[6.0]
  def change
    rename_column :feeds, :last_visited, :refresh_at
  end
end
