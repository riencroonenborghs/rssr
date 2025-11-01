# frozen_string_literal: true

module Tagger
  extend ActiveSupport::Concern

  class_methods do
    def tagger
      include TaggerMethods
    end
  end

  module TaggerMethods
    extend ActiveSupport::Concern

    included do
      has_many :taggings, as: :taggable, dependent: :destroy
      has_many :tags, through: :taggings

      scope :tagged_with, -> (tag) { Tagging.where(taggable_type: self.table_name.classify).joins(:tag).where(tags: { name: tag.upcase } ) }

      def tag_list
        tags.to_a
      end

      def tag_list=(tag_list)
        tag_list = tag_list.split(",") if tag_list.is_a?(String)
        ActiveRecord::Base.transaction do
          tag_list.map(&:lstrip).map(&:upcase).each do |name|
            unless (tag = Tag.find_by(name: name))
              tag = Tag.create!(name: name)
            end
            next if Tagging.exists?(taggable: self, tag_id: tag.id)

            Tagging.create(taggable: self, tag_id: tag.id)
          end
        end
      end
    end
  end
end
