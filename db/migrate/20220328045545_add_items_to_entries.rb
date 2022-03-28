class AddItemsToEntries < ActiveRecord::Migration[6.0]
  def change
    rename_column :entries, :url, :link
    rename_column :entries, :entry_id, :guid
    rename_column :entries, :summary, :description
    rename_column :entries, :image_url, :image

    { media_title: :string, media_url: :string, media_type: :string,
      media_width: :integer, media_height: :integer,
      media_thumbnail_url: :string, media_thumbnail_height: :integer, media_thumbnail_width: :integer,
      enclosure_length: :integer, enclosure_type: :string, enclosure_url: :string,
      itunes_duration: :string, itunes_episode_type: :string, itunes_author: :string,
      itunes_explicit: :boolean, itunes_image: :string, itunes_title: :string, itunes_summary: :string }.each do |name, type|
        add_column :entries, name, type
      end
  end
end
