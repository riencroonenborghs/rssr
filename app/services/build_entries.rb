# frozen_string_literal: true

class BuildEntries
  include Base

  attr_reader :entries

  def initialize(feed:, feed_data:)
    @feed = feed
    @feed_data = feed_data
    @entries = {}
  end

  def perform
    @entries = entries_to_add.map do |entry|
      description = entry_description(entry)
      title = entry_title(entry, description)

      hash = {
        title: title,
        link: entry_link(entry),
        published_at: entry_published_at(entry),
        description: description,
        guid: entry_guid(entry),
        tag_list: entry_tag_list(entry)
      }

      %i[image].each do |media|
        hash[media] = entry.send(media) if entry.respond_to?(media)
      end

      hash
    end
  end

  private

  def entries_to_add
    new_guids = @feed_data.entries.map { |entry| entry_guid(entry) }.compact
    existing_guids = @feed.entries.where(guid: new_guids).pluck(:guid)

    new_guids -= existing_guids
    @feed_data.entries.select { |entry| new_guids.include?(entry_guid(entry)) }
  end

  def entry_description(entry)
    content = entry.content if entry.respond_to?(:content)
    summary = entry.summary if entry.respond_to?(:summary)
    description = entry.description if entry.respond_to?(:description)
    content || summary || description
  end

  def entry_title(entry, description)
    title = entry.respond_to?(:title) ? entry.title : description.split(".")[0]
    return "No title." unless title

    title.gsub("\n", "")
  end

  def entry_link(entry)
    url = entry.url if entry.respond_to?(:url)
    link = entry.link if entry.respond_to?(:link)

    url || link
  end

  def entry_published_at(entry)
    return entry.published if entry.respond_to?(:published)
    return entry.published_at if entry.respond_to?(:published_at)

    nil
  end

  def entry_guid(entry)
    guid = entry.guid if entry.respond_to?(:guid)
    entry_id = entry.entry_id if entry.respond_to?(:entry_id)
    id = entry.id if entry.respond_to?(:id)

    guid || entry_id || id
  end

  def entry_tag_list(entry)
    return entry.categories if entry.respond_to?(:categories)

    nil
  end
end
