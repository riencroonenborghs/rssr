module ApplicationHelper
  def tag_links(feed)
    content_tag :span do
      tag_list = feed.tag_list.each do |tag|
        concat(
          tag_link(tag, klass: "pe-1")
        )
      end
    end
  end

  def tag_link(tag, klass: "")
    link_to content_tag(:span, tag.upcase, class: "badge rounded-pill"), tagged_feeds_path(tag.upcase), class: klass
  end

  def clean_summary(entry)
    return unless entry.summary
    
    sanitized = sanitize(entry.summary, tags: %w(strong em p a))
    sanitized.gsub(/\<a /, "<a target='_blank' ")
  end

  def clean_summary2(entry)
    clean_summary(entry).first(50) + " ..."
  end
end
