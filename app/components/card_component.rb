# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_one :body
  renders_one :footer

  def initialize(subscription:) # rubocop:disable Lint/MissingSuper
    @subscription = subscription
  end
end
