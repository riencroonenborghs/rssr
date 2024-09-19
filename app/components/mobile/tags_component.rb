# frozen_string_literal: true

module Mobile
  class TagsComponent < ViewComponent::Base
    def initialize(tags:) # rubocop:disable Lint/MissingSuper
      @tags = tags
    end
  end
end
