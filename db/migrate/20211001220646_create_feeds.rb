class CreateFeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :feeds do |t|
      t.references :user, null: false, foreign_key: true
      t.string :url, null: false
      t.string :title, null: false
      t.boolean :active, null: false, default: true
      t.datetime :last_visited

      t.timestamps
    end
  end
end
