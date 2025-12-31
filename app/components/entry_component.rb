# frozen_string_literal: true

class EntryComponent < ViewComponent::Base
  include ComponentScopeHelpers

  def initialize(entry: nil) # rubocop:disable Lint/MissingSuper
    @entry = entry
  end

  def before_render
    sanitize_description
    @bookmarked = @entry&.bookmarked?(current_user)
  end

  def sanitize_description
    return unless @entry&.description

    @entry.description = sanitize(@entry.description, tags: %w[strong em p a])
    @entry.description = @entry.description.gsub("<a ", "<a target='_blank' ")
  end
end
