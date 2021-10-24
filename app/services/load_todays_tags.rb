class LoadTodaysTags < AppService
  attr_reader :tags, :tag_count_by_tag, :feeds_by_tag, :entries, :entries_by_tag_by_feed

  def call
    @feeds_by_tag = {}
    @entries = {}
    @entries_by_tag_by_feed = {}
    entry_scope.group_by(&:feed).each do |feed, entry_list|
      feed.tag_list.each do |tag|
        feeds_by_tag[tag] ||= []
        entries[tag] ||= []

        entries_by_tag_by_feed[tag] ||= {}
        entries_by_tag_by_feed[tag][feed] ||= []

        feeds_by_tag[tag] << feed
        entries[tag].concat(entry_list)

        entries_by_tag_by_feed[tag][feed].concat(entry_list.select { |entry| entry.feed_id == feed.id })
      end
    end

    @tags = feeds_by_tag.keys.sort
    @tag_count_by_tag = {}.tap do |data|
      entries.each do |tag, list|
        data[tag] = list.size
      end
    end
  end

  private

  def entry_scope
    Entry
      .includes(:feed)
      .joins(:feed)
      .merge(Feed.active)
      .most_recent_first
      .last_24h
  end
end