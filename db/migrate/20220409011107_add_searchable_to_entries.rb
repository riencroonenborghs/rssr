class AddSearchableToEntries < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TABLE entries ADD COLUMN searchable tsvector;
      UPDATE entries SET searchable =
          to_tsvector('english', coalesce(title,'') || ' ' || coalesce(description,''));
    SQL

    add_index :entries, :searchable, using: :gin, algorithm: :concurrently
  end

  def down
    remove_column :entries, :searchable
  end
end
