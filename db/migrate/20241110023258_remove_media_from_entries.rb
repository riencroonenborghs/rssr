class RemoveMediaFromEntries < ActiveRecord::Migration[6.1]
  def change
    remove_column :entries, :media_height
    remove_column :entries, :media_thumbnail_height
    remove_column :entries, :media_thumbnail_url
    remove_column :entries, :media_thumbnail_width
    remove_column :entries, :media_title
    remove_column :entries, :media_type
    remove_column :entries, :media_url
    remove_column :entries, :media_width
  end
end
