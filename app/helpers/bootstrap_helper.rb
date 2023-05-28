module BootstrapHelper
  def bootstrap_tags(subscription)
    content_tag :span do
      subscription.tag_list.each do |tag|
        concat(
          bootstrap_tag(tag, klass: "me-1")
        )
      end
    end
  end

  def cached_bootstrap_tags(tag_list)
    content_tag :span do
      (tag_list || []).each do |tag|
        concat(
          bootstrap_tag(tag, klass: "me-1")
        )
      end
    end
  end

  def bootstrap_tag(tag, klass: "")
    link_to content_tag(:span, tag.upcase, class: "badge tag fs-15"), tagged_feeds_path(tag.upcase), class: klass
  end
end
