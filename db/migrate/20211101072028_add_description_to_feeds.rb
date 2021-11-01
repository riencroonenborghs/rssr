class AddDescriptionToFeeds < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :description, :text
  end
end
