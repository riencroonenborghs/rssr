module ApplicationHelper
  def active_page?(path)
    request.fullpath.start_with?(path)
  end

  def clean_summary(entry)
    return unless entry.summary

    sanitized = sanitize(entry.summary, tags: %w[strong em p a])
    sanitized.gsub(/\<a /, "<a target='_blank' ") # rubocop:disable Style/RedundantRegexpEscape
  end
end
