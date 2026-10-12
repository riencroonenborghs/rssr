class CreateRssEntryReads < ActiveRecord::Migration[8.1]
  def change
    create_table :rss_entry_reads do |t|
      t.references :user, null: false, foreign_key: true
      # Cascade so bulk deletes of entries (RssEntries::PurgeOldJob) also remove their reads.
      t.references :rss_entry, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
    add_index :rss_entry_reads, [ :user_id, :rss_entry_id ], unique: true
  end
end
