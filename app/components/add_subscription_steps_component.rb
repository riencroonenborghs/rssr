# frozen_string_literal: true

class AddSubscriptionStepsComponent < ViewComponent::Base
  def initialize(step:) # rubocop:disable Lint/MissingSuper
    @step = step
  end
end
