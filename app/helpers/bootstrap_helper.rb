module BootstrapHelper
  def bootstrap_tags(feed)
    content_tag :span do
      feed.tag_list.each do |tag|
        concat(
          bootstrap_tag(tag, klass: "me-1")
        )
      end
    end
  end

  def bootstrap_tag(tag, klass: "")
    link_to content_tag(:span, tag.upcase, class: "badge tag fs-11"), tagged_feeds_path(tag.upcase), class: klass
  end
end
