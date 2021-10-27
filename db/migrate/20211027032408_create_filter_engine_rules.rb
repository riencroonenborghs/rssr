class CreateFilterEngineRules < ActiveRecord::Migration[6.0]
  def change
    create_table :filter_engine_rules do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false, default: "keyword"
      t.string :comparison, null: false, default: "eq"
      t.string :value, null: false
      t.timestamps
    end
  end
end
