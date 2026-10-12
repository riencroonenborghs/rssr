class CreateFilters < ActiveRecord::Migration[8.1]
  def change
    create_table :filters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :value, null: false

      t.timestamps
    end
    add_index :filters, [ :user_id, :kind, :value ], unique: true
  end
end
