module ApplicationHelper
  def tags(feed, class_name = "bg-primary")
    ("<span>" + feed.tag_list.map do |tag|
      "<span class=\"badge rounded-pill #{class_name}\">#{tag}</span> "
    end.join(" ") + "</span>").html_safe
  end
end
