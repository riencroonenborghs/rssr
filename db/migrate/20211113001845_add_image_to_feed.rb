class AddImageToFeed < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :image_url, :string
  end
end
