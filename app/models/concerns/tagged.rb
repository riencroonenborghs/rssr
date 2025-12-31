# frozen_string_literal: true

module Tagged
  extend ActiveSupport::Concern

  class_methods do
    def tagged
      include TaggerMethods
    end
  end

  module TaggerMethods
    extend ActiveSupport::Concern

    included do
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings

      scope :tagged_with, ->(tag) do # rubocop:disable Style/Lambda
        scope = Tagging.where(taggable_type: table_name.classify).joins(:tag)
        scope = tag.is_a?(String) ? scope.where(tags: { name: tag.upcase }) : scope.where(tags: { id: tag.id })
        where(id: scope.select(:taggable_id))
      end
    end

    def add_tags(tag_names)
      tag_names = tag_names.split(",").map(&:strip) if tag_names.is_a?(String)
      tag_names.each do |tag_name|
        tag = Tag.find_or_create_by(name: tag_name.upcase)
        next if Tagging.exists?(taggable: self, tag_id: tag.id)

        Tagging.create(taggable: self, tag_id: tag.id)
      end
    end

    def remove_tags(tag_names)
      tag_names = tag_names.split(",").map(&:strip) if tag_names.is_a?(String)
      Tagging.joins(:tag).where(taggable: self).where(tags: { name: tag_names.map(&:upcase) }).destroy_all
    end
  end
end
