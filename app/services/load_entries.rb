class LoadEntries < AppService
  attr_reader :feed

  def initialize(feed:)
    @feed = feed
  end

  def call
    @entries_by_entry_id = feed.entries.index_by(&:entry_id)

    entries.each do |entry|
      create_new_entry(entry)
    end
  end
  
  private

  attr_reader :entries_by_entry_id

  def entries    
    loader = LoadFeed.call(feed: feed)
    if loader.failure?
      errors.merge!(loader.errors)
      return []
    end
    
    loader.loaded_feed.entries
  end

  def create_new_entry(entry)
    entry_id = entry.entry_id || entry.url
    return if @entries_by_entry_id[entry_id]

    feed.entries.create!(
      entry_id: entry_id,
      url: entry.url,
      title: entry.title || "No title :(",
      summary: entry.summary,
      published_at: entry.published.in_time_zone,
      image_url: entry.image
    )
  end
end