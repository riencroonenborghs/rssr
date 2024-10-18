# frozen_string_literal: true

class FilterEntries
  include Base

  attr_reader :user, :scope

  def initialize(user:, scope:)
    @user = user
    @scope = scope
  end

  def perform
    return unless user.filters.any?

    @scope = scope.merge(
      generate_includes_filters
    ).merge(
      generate_excludes_filters
    ).merge(
      generate_matches_filters
    ).merge(
      generate_mismatches_filters
    ).merge(
      generate_tagged_filters
    )
  end

  private

  attr_reader :filters

  def generate_filter_string(comparison)
    user
      .filters
      .where(comparison: comparison)
      .select(:value)
      .pluck(:value)
      .map { |value| "'%#{value.upcase}%'" }
  end

  def generate_filter_re(comparison)
    user
      .filters
      .where(comparison: comparison)
      .select(:value)
      .pluck(:value)
      .map(&:upcase)
      .join("|")
  end

  def generate_includes_filters
    filters = generate_filter_string("includes")
    return scope unless filters.any?
    
    if ActiveRecord::Base.connection_db_config.adapter == "sqlite3"
      sql = filters.map { |v| "upper(entries.title) like #{v}" }.join(" OR ")
      scope.where.not(sql)
    else
      scope.where.not("upper(entries.title) like any (array[#{filters.join(", ")}])")
    end
  end

  def generate_excludes_filters
    filters = generate_filter_string("excludes")
    return scope unless filters.present?

    if ActiveRecord::Base.connection_db_config.adapter == "sqlite3"
      sql = filters.map { |v| "upper(entries.title) not like #{v}" }.join(" OR ")
      scope.where.not(sql)
    else
      scope.where.not("upper(entries.title) not like any (array[#{filters.join(", ")}])")
    end
  end

  def generate_matches_filters
    filters = generate_filter_re("matches")
    return scope unless filters.present? && ActiveRecord::Base.connection_db_config.adapter != "sqlite3"

    scope.where.not("upper(entries.title) ~ '#{filters}'")
  end

  def generate_mismatches_filters
    filters = generate_filter_re("mismatches")
    return scope unless filters.present? && ActiveRecord::Base.connection_db_config.adapter != "sqlite3"

    scope.where.not("upper(entries.title) !~ '#{filters}'")
  end

  def generate_tagged_filters
    tags = user
      .filters
      .where(comparison: "tagged")
      .select(:value)
      .pluck(:value)
      .map(&:upcase)
    return scope unless tags.any?
    
    entry_scope = scope.tagged_with(tags, exclude: true)
    subscription_scope = scope.where(feed_id: @user.subscriptions.active.tagged_with(tags, exclude: true).select(:feed_id))
    
    entry_scope.merge(subscription_scope)
  end
end
