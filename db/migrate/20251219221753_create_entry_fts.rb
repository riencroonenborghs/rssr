class CreateEntryFts < ActiveRecord::Migration[7.2]
  def up
    execute "CREATE VIRTUAL TABLE entry_titles USING fts5(entry_id, title);"

    Entry.find_each do |entry|
      entry.save!
    end    
  end

  def down
    execute "DROP TABLE entry_titles"
  end
end
