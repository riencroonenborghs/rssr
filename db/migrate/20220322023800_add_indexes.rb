class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :entries, :entry_id
    add_index :entries, :published_at
    add_index :entries, [:feed_id, :entry_id]

    add_index :feeds, :url
    add_index :feeds, :active
    add_index :feeds, :last_visited
    
    add_index :filter_engine_rules, [:value, :user_id, :type], name: "uniq_filter_val_usr_type"

    add_index :read_later_entries, :read
    add_index :read_later_entries, [:user_id, :entry_id, :read], name: "readltr_usr_entry_rd"

    add_index :subscriptions, :active
    add_index :subscriptions, [:user_id, :feed_id, :active], name: "sub_usr_fd_actv"
  end
end
