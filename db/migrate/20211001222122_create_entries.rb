class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.references :feed, null: false, foreign_key: true
      t.string :entry_id, null: false
      t.string :url, null: false
      t.string :title, null: false
      t.string :summary
      t.datetime :published_at, null: false
      t.string :image_url

      t.timestamps
    end
  end
end
