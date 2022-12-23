# frozen_string_literal: true

class CreateEntriesService
  include Base

  def initialize(feed:)
    @feed = feed
    @refresh_at = feed.refresh_at
  end

  def perform
    load_new_entries
    return unless success?

    create_new_rss_items
    return unless success?

    feed.update(refresh_at: Time.zone.now)
  end

  private

  attr_reader :feed, :refresh_at, :new_entries

  def load_new_entries
    loader = GetFeedDataService.perform(feed: feed)
    errors.merge!(loader.errors) and return unless loader.success?

    @new_entries = loader.feed_data.entries
  end

  def entries_to_add
    new_guids = new_entries.map { |entry| entry_guid(entry) }.compact
    existing_guids = feed.entries.where(guid: new_guids).pluck(:guid)

    new_guids -= existing_guids
    new_entries.select { |entry| new_guids.include?(entry_guid(entry)) }
  end

  def create_new_rss_items
    Entry.transaction do
      feed.entries.create!(
        entries_to_add.map do |entry|
          description = entry_description(entry)
          title = entry_title(entry, description)

          hash = {
            title: title,
            link: entry_link(entry),
            published_at: entry_published_at(entry),
            description: description,
            guid: entry_guid(entry)
          }
          %i[image media_title media_url media_type media_width media_height media_thumbnail_url media_thumbnail_width media_thumbnail_height enclosure_length enclosure_type enclosure_url itunes_duration itunes_episode_type itunes_author itunes_explicit itunes_image itunes_title itunes_summary].each do |media|
            hash[media] = entry.send(media) if entry.respond_to?(media)
          end

          hash
        end
      )
    end
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
    media_url = entry.media_url if entry.respond_to?(:media_url)

    url || link || media_url
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
end
