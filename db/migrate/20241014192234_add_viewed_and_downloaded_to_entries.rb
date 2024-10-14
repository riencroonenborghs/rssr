class AddViewedAndDownloadedToEntries < ActiveRecord::Migration[6.1]
  def change
    add_column :entries, :viewed_at, :datetime
    add_column :entries, :downloaded_at, :datetime

    add_index :entries, :viewed_at
    add_index :entries, :downloaded_at
    add_index :entries, [:viewed_at, :downloaded_at]
  end
end
