# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ApplicationRecord
  validates :name, uniqueness: true
  before_save :uppercase_name

  has_many :taggings

  after_save :create_or_update_searchable_tags
  after_destroy :remove_searchable_tags

  def uppercase_name
    self.name = name.upcase
  end

  private

  def create_or_update_searchable_tags
    taggings.select(:taggable_type, :taggable_id).each do |tagging|
      SearchableTag.find_or_create_by(taggable_type: tagging.taggable_type, taggable_id: tagging.taggable_id, tag_name: name)
    end
  end

  def remove_searchable_tags
    taggings.select(:taggable_type, :taggable_id).each do |tagging|
      SearchableTag.where(taggable_type: tagging.taggable_type, taggable_id: tagging.taggable_id).delete_all
    end
  end
end
