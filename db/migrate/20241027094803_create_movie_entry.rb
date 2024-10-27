class CreateMovieEntry < ActiveRecord::Migration[6.1]
  def change
    create_table :movie_entries do |t|
      t.references :entry, null: false, foreign_key: true
      t.string :name
      t.integer :year
      t.string :resolution
      t.boolean :cam

      t.timestamps
    end
  end
end
