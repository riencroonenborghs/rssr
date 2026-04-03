class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.string :keywords, null: false
      t.integer :report_type, null: false, default: 0
      t.datetime :last_generated_at

      t.timestamps
    end
    add_index :reports, [:user_id, :report_type]
  end
end
