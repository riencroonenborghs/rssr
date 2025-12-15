# frozen_string_literal: true

class EntryParser
  def initialize(entry:)
    @entry = entry
  end

  def guid
    @guid ||= begin
      guid = @entry.guid if @entry.respond_to?(:guid)
      entry_id = @entry.entry_id if @entry.respond_to?(:entry_id)
      id = @entry.id if @entry.respond_to?(:id)
      guid || entry_id || id
    end
  end

  def description
    @description ||= begin
      content = @entry.content if @entry.respond_to?(:content)
      summary = @entry.summary if @entry.respond_to?(:summary)
      description = @entry.description if @entry.respond_to?(:description)
      content || summary || description
    end
  end

  def title
    if @entry.respond_to?(:title)
      @entry.title.gsub("\n", "")
    elsif description
      description.split(".")[0].gsub("\n", "")
    else
      "No title"
    end
  end

  def link
    url = @entry.url if @entry.respond_to?(:url)
    link = @entry.link if @entry.respond_to?(:link)
    media_url = @entry.media_url if @entry.respond_to?(:media_url)
    url || link || media_url
  end

  def published_at
    return @entry.published if @entry.respond_to?(:published)
    return @entry.published_at if @entry.respond_to?(:published_at)

    nil
  end

  def tag_list
    @entry.respond_to?(:categories) ? @entry.categories : []
  end

  def image
    return @entry.image if @entry.respond_to?(:image)

    nil
  end
end
