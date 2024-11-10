class RemoveItunesFromEntries < ActiveRecord::Migration[6.1]
  def change
    remove_column :entries, :itunes_author
    remove_column :entries, :itunes_duration
    remove_column :entries, :itunes_episode_type
    remove_column :entries, :itunes_explicit
    remove_column :entries, :itunes_image
    remove_column :entries, :itunes_summary
    remove_column :entries, :itunes_title
  end
end
