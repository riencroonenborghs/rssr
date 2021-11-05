class CreateReadLaterEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :read_later_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true

      t.timestamps
    end

    add_index :read_later_entries, [:user_id, :entry_id]
  end
end
