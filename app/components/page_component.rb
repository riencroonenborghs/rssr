# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  delegate :user_signed_in?, :current_user, to: :helpers
  renders_many :entries

  def initialize(entries:)
    @entries = entries

    @twenty_fours_h_ago = 24.hours.ago
    @tags_by_subscription ||= {}
    @subscription_by_feed ||= {}
  end

  def before_render
    set_tags_by_subscription
    set_subscription_by_feed
    set_tags
    set_bookmarks
    set_viewed
  end

  private

  def set_tags_by_subscription
    @tags_by_subscription = {}.tap do |ret|
      ActsAsTaggableOn::Tagging.includes(:tag).where(taggable_type: "Subscription", taggable_id: 
        Subscription.joins(feed: :entries).merge(Entry.where(id: @entries.select(&:id)))
      ).each do |tagging|
        ret[tagging.taggable_id] ||= []
        ret[tagging.taggable_id] << tagging.tag.name.upcase
      end
    end
  end

  def set_subscription_by_feed
    @subscription_by_feed = Subscription
      .joins(feed: :entries)
      .merge(
        Entry.where(id: @entries.select(&:id))
      )
      .index_by(&:feed_id)
  end

  def set_tags
    return @tags = [] unless user_signed_in?

    @tags = ActsAsTaggableOn::Tag.where(id: 
      ActsAsTaggableOn::Tagging.where(taggable_type: "Subscription", taggable_id: 
        Subscription.active.where(user_id: current_user.id).select(&:id)
      ).select(:tag_id)
    ).distinct(:name).pluck(:name).sort.map(&:upcase)
  end

  def set_bookmarks
    @bookmarks = user_signed_in? ? Bookmark.unread.where(user_id: current_user.id).map(&:entry_id) : []
  end

  def set_viewed
    return @viewed = [] unless user_signed_in?

    entry_ids = @entries.map(&:id).uniq
    @viewed = ViewedEntry.where(user_id: current_user.id, entry_id: entry_ids).map(&:entry_id)
  end
end
