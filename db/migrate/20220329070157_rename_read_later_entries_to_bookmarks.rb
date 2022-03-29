class RenameReadLaterEntriesToBookmarks < ActiveRecord::Migration[6.0]
  def change
    rename_table :read_later_entries, :bookmarks
  end
end
