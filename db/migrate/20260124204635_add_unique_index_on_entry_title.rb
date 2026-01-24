class AddUniqueIndexOnEntryTitle < ActiveRecord::Migration[7.2]
  def change
    Entry.group(:feed_id, :title).count.select{|k,v| v > 1}.each do |key, value|
      feed_id, title = key
      to_remove = Entry.where(feed_id: feed_id, title: title).limit(value)
      to_remove.map(&:destroy)
    end

    add_index :entries, [:feed_id, :title], unique: true
  end
end
