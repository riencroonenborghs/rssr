# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_one :body
  renders_one :footer

  def initialize(highlighted: false) # rubocop:disable Lint/MissingSuper
    @highlighted = highlighted
  end
end
