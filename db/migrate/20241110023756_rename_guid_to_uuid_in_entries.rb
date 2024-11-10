class RenameGuidToUuidInEntries < ActiveRecord::Migration[6.1]
  def change
    rename_column :entries, :guid, :uuid
  end
end
