# frozen_string_literal: true

class IconComponent < ViewComponent::Base
  def initialize(name:, size: 6) # rubocop:disable Lint/MissingSuper
    @name = name
    @size = size
  end
end
