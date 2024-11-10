class RemoveEnclosureFromEntries < ActiveRecord::Migration[6.1]
  def change
    remove_column :entries, :enclosure_length
    remove_column :entries, :enclosure_type
    remove_column :entries, :enclosure_url
  end
end
