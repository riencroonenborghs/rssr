class LoadTodaysTags < AppService
  attr_reader :tags, :tag_count_by_tag, :feeds_by_tag, :entries_by_tag_by_feed

  def call
    parse_entry_scope
    parse_tags
  end

  private

  attr_reader :entries

  def entry_scope
    Entry
      .includes(feed: :base_tags)
      .joins(feed: :base_tags)
      .merge(Feed.active)
      .most_recent_first
      .today
  end

  def parse_entry_scope
    @feeds_by_tag = {}
    @entries = {}
    @entries_by_tag_by_feed = {}

    entry_scope.group_by(&:feed).each do |feed, entry_list|
      feed.base_tags.each do |tag|
        parse_feed_and_tag(feed, tag, entry_list)
      end
    end
  end

  def parse_feed_and_tag(feed, tag, entry_list) # rubocop:disable Metrics/AbcSize
    feeds_by_tag[tag] ||= []
    entries[tag] ||= []

    entries_by_tag_by_feed[tag] ||= {}
    entries_by_tag_by_feed[tag][feed] ||= []

    feeds_by_tag[tag] << feed
    entries[tag].concat(entry_list)

    entries_by_tag_by_feed[tag][feed].concat(
      entries_for_feed(entry_list, feed)
    )
  end

  def entries_for_feed(entry_list, feed)
    entry_list.select { |entry| entry.feed_id == feed.id }
  end

  def parse_tags
    @tags = feeds_by_tag.keys.sort { |x, y| x.name <=> y.name }
    @tag_count_by_tag = {}.tap do |data|
      entries.each do |tag, list|
        data[tag] = list.size
      end
    end
  end
end
