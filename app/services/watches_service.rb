class WatchesService
  include AppService

  attr_reader :user, :scope

  def initialize(user:, scope:)
    @user = user
    @scope = scope
  end

  def call
    return unless user.watches.any?

    user.watches.group_by(&:group_id).each do |_, group|
      add_group_to_scope(group: group)
    end
    
    # return unless or_scope.where_clause.any?

    # @scope = scope.where(or_scope.where_clause.ast.not.to_sql).distinct
    # @scope = scope.joins(joins_clause) if joins_clause.any?
  end

  private

  def add_group_to_scope(group:)
    scopes = group.reject(&:tagged?).map do |watch|
      add_watch_to_scope(scope: Entry, watch: watch)
    end

    tag_scopes = group.select(&:tagged?).map do |watch|
      add_watch_to_scope(scope: Entry, watch: watch)
    end

    scope = scopes.shift
    scopes.each do |other_scope|
      scope = scope.or(other_scope)
    end

    scope
  end

  def add_watch_to_scope(scope:, watch:)
    values = watch.value.upcase.split(",")

    case watch.watch_type
    when Watch::ENTRY_TITLE
      values.map { |title| scope = entry_title_scope(scope: scope, title: title) }
    when Watch::ENTRY_DESCRIPTION
      values.map { |description| scope = entry_description_scope(scope: scope, description: description) }
    when Watch::FEED_TAG
      values.map { |tag| scope = feed_tag_scope(scope: scope, tag: tag) }
    end

    scope
  end

  def entry_title_scope(scope:, title:)
    scope.where("upper(entries.title) like ?", "%#{title.upcase}%")
  end

  def entry_description_scope(scope:, description:)
    scope.where("upper(entries.description) like ?", "%#{description.upcase}%")
  end

  def feed_tag_scope(scope:, tag:)
    scope.joins(feed: { taggings: :tag }).merge(Feed.tagged_with(tag.upcase))
  end

  # def joins_clause
  #   @joins_clause ||= or_scope.joins_values
  # end
end
