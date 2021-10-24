class AddErrorToFeeds < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :error, :text
  end
end
