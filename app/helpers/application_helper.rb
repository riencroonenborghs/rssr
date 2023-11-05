# frozen_string_literal: true

module ApplicationHelper
  def active_page?(path)
    request.fullpath.start_with?(path)
  end

  # rubocop:disable Style/RedundantRegexpArgument
  # rubocop:disable Style/RedundantRegexpEscape
  def clean_description(entry)
    return unless entry.description

    sanitized = sanitize(entry.description, tags: %w[strong em p a])
    sanitized.gsub(/\<a /, "<a target='_blank' ")
  end
  # rubocop:enable Style/RedundantRegexpArgument
  # rubocop:enable Style/RedundantRegexpEscape
end
