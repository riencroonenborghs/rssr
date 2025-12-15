# frozen_string_literal: true

class BookmarkComponent < ViewComponent::Base
  include ComponentScopeHelpers

  def initialize(entry:, bookmarked:)
    @entry = entry
    @bookmarked = bookmarked
  end
end
