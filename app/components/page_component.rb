# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  delegate :user_signed_in?, :current_user, :mobile?, to: :helpers
  renders_many :entries

  def initialize(entries:, skip_viewed: false) # rubocop:disable Lint/MissingSuper
    @entries = entries
    @skip_viewed = skip_viewed

    @twenty_fours_h_ago = 24.hours.ago
    @tags_by_subscription ||= {}
    @subscription_by_feed ||= {}
    @tags = []
    @viewed = []
  end

  def before_render
    set_tags_by_subscription
    set_subscription_by_feed
    set_tags
    set_viewed
  end

  private

  def set_tags_by_subscription
    entries = Entry.where(id: @entries.select(&:id))
    subscription_ids = Subscription.joins(feed: :entries).merge(entries).select(:id)

    @tags_by_subscription = {}.tap do |ret|
      ActsAsTaggableOn::Tagging
        .includes(:tag)
        .where(taggable_type: "Subscription", taggable_id: subscription_ids)
        .each do |tagging|
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
    return unless user_signed_in?

    subscription_ids = Subscription.active.where(user_id: current_user.id).select(:id)
    tag_ids = ActsAsTaggableOn::Tagging.where(taggable_type: "Subscription", taggable_id: subscription_ids).select(:tag_id)

    @tags = ActsAsTaggableOn::Tag.where(id: tag_ids).distinct(:name).pluck(:name).sort.map(&:upcase)
  end

  def set_viewed
    return unless user_signed_in?
    return if @skip_viewed

    entry_ids = @entries.map(&:id).uniq
    @viewed = ViewedEntry.where(user_id: current_user.id, entry_id: entry_ids).map(&:entry_id)
  end
end
