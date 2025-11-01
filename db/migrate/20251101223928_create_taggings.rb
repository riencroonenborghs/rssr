# frozen_string_literal: true

class CreateTaggings < ActiveRecord::Migration[6.1]
  def change
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: true
      t.integer :taggable_id
      t.string :taggable_type

      t.timestamps
    end
    add_index :taggings, [:taggable_type, :taggable_id]
  end
end