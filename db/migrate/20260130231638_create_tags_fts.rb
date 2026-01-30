class CreateTagsFts < ActiveRecord::Migration[7.2]
  def up
    execute "DROP TABLE IF EXISTS searchable_tags_data"
    execute "DROP TABLE IF EXISTS searchable_tags_docsize"
    execute "CREATE VIRTUAL TABLE searchable_tags USING fts5(taggable_type, taggable_id, tag_name)"

    Tagging
      .joins(:tag)
      .select(taggings: [:taggable_type, :taggable_id], tags: [:name]).each do |tagging|
        SearchableTag.create(
          taggable_type: tagging.taggable_type,
          taggable_id: tagging.taggable_id,
          tag_name: tagging.name
        )
      end
  end

  def down
    execute "DROP TABLE searchable_tags;"
  end
end
