# frozen_string_literal: true

module Mobile
  class TagsComponent < ViewComponent::Base
    def initialize(tags:, entry_tags:) # rubocop:disable Lint/MissingSuper
      @tags = tags
      @entry_tags = entry_tags
    end
  end
end
