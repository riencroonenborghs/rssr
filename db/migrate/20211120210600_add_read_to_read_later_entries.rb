class AddReadToReadLaterEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :read_later_entries, :read, :datetime
  end
end
