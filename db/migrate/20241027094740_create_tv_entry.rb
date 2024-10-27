class CreateTvEntry < ActiveRecord::Migration[6.1]
  def change
    create_table :tv_entries do |t|
      t.references :entry, null: false, foreign_key: true
      t.string :name
      t.integer :season
      t.integer :episode
      t.string :resolution

      t.timestamps
    end
  end
end
