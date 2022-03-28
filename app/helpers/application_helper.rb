module ApplicationHelper
  def active_page?(path)
    request.fullpath.start_with?(path)
  end

  def clean_description(entry)
    return unless entry.description

    sanitized = sanitize(entry.description, tags: %w[strong em p a])
    sanitized.gsub(/\<a /, "<a target='_blank' ") # rubocop:disable Style/RedundantRegexpEscape
  end
end
