module ApplicationHelper
  def tags(feed)
    content_tag :span do
      tag_list = feed.tag_list.each do |tag|
        concat(
          link_to content_tag(:span, tag, class: "badge rounded-pill"), by_tag_feeds_path(tag), class: "ps-1"
        )
      end
    end
  end

  def clean_summary(entry)
    return unless entry.summary
    
    sanitized = sanitize(entry.summary, tags: %w(strong em p a))
    sanitized.gsub(/\<a /, "<a target='_blank' ")
  end
end
