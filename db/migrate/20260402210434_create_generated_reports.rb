class CreateGeneratedReports < ActiveRecord::Migration[7.2]
  def change
    create_table :generated_reports do |t|
      t.references :report, null: false, foreign_key: true
      t.string :summary, null: false
      t.string :prompt, null: false

      t.timestamps
    end
  end
end
