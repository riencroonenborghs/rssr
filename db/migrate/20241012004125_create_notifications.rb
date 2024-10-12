class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.integer :watch_group_id, null: false
      t.datetime :acked_at

      t.timestamps
    end
  end
end
