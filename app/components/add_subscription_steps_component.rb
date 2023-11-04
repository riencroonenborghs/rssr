# frozen_string_literal: true

class AddSubscriptionStepsComponent < ViewComponent::Base
  def initialize(step:)
    no_steps = 4
    @step = step
  end
end
