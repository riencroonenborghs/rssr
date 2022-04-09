class CreateWatches < ActiveRecord::Migration[6.0]
  def change
    create_table :watches do |t|
      t.references :user, null: false, foreign_key: true
      t.string :watch_type, null: false
      t.string :value, null: false
      t.integer :group_id, null: false, default: 0
      t.timestamps
    end

    add_index :watches, [:value, :watch_type, :user_id], name: "uniq_watch_combniation"
  end
end
