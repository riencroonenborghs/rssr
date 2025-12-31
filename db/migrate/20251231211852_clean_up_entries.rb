class CleanUpEntries < ActiveRecord::Migration[7.2]
  def up
    column_names = %w[enclosure_length enclosure_type enclosure_url itunes_author itunes_duration itunes_episode_type itunes_explicit itunes_image itunes_summary itunes_title media_height media_thumbnail_height media_thumbnail_url media_thumbnail_width media_title media_type media_url media_width]

    column_names.each do |column_name|
      remove_column :entries, column_name
    end

    rename_column :entries, :guid, :uuid
  end
end
