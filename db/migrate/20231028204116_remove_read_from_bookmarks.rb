class RemoveReadFromBookmarks < ActiveRecord::Migration[6.0]
  def change
    remove_column :bookmarks, :read
  end
end
