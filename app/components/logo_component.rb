# frozen_string_literal: true

class LogoComponent < ViewComponent::Base
  def initialize(feed:, mark_viewed: false) # rubocop:disable Lint/MissingSuper
    @name = feed.name
    @name = @name.split(/ /).first(2).map(&:first).compact.join
    @mark_viewed = mark_viewed
  end
end
