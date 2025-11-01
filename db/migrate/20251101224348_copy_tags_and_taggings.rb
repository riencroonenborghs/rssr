class CopyTagsAndTaggings < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO tags (id, name, created_at, updated_at)
      SELECT id, name, created_at, updated_at  FROM old_tags;

      INSERT INTO taggings (id, tag_id, taggable_type, taggable_id, created_at, updated_at)
      SELECT id, tag_id, taggable_type, taggable_id, created_at, created_at FROM old_taggings;
    SQL
  end

  def down
  end
end
