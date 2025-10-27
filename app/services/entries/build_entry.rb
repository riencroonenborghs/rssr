# frozen_string_literal: true

module Entries
  class BuildEntry
    include Base

    attr_reader :hash

    def initialize(entry:)
      @entry = entry
      @hash = {}
    end

    def perform
      @hash = {
        title: title,
        link: link,
        published_at: published_at,
        description: description,
        guid: Entry.parse_guid(@entry),
        # tag_list: tag_list
      }
    end

    private

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
        "No title."
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
      return @entry.categories if @entry.respond_to?(:categories)

      nil
    end
  end
end
