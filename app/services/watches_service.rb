class WatchesService
  include AppService

  attr_reader :scope, :watches

  def initialize(scope:, watches:)
    @scope = scope
    @watches = watches
  end

  def call
    return unless watches.any?

    watches.each { |watch| add_watch_scope(watch: watch) }

    @scope = scope.most_recent_first.distinct
  end

  private

  def add_watch_scope(watch:)
    values = watch.value.upcase.split(",")

    case watch.watch_type
    when Watch::ENTRY_TITLE
      values.each { |title| add_entry_title_scope(title: title) }
    when Watch::ENTRY_DESCRIPTION
      values.each { |description| add_entry_description_scope(description: description) }
    when Watch::FEED_TAG
      values.each { |tag| add_feed_tag_scope(tag: tag) }
    end
  end

  def add_entry_title_scope(title:)
    @scope = scope.where("upper(entries.title) like ?", "%#{title.upcase}%")
  end

  def add_entry_description_scope(description:)
    @scope = scope.where("upper(entries.description) like ?", "%#{description.upcase}%")
  end

  def add_feed_tag_scope(tag:)
    @scope = scope.joins(feed: { taggings: :tag }).merge(Feed.tagged_with(tag.upcase))
  end
end
