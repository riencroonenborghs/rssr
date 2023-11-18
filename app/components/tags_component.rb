# frozen_string_literal: true

class TagsComponent < ViewComponent::Base
  def initialize(tags:, subscription_based: true) # rubocop:disable Lint/MissingSuper
    @tags = tags
    @subscription_based = subscription_based
  end
end
