# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :set_feed

  def index
    set_entries
  end

  def show
    @entry = @feed.entries.find(params[:id])

    unless mobile? # rubocop:disable Style/GuardClause
      show_set_tags_by_subscription
      show_set_subscription_by_feed
    end
  end

  private

  def set_feed
    @feed = if user_signed_in?
              current_user.feeds.find(params[:feed_id])
            else
              Feed.find(params[:feed_id])
            end
  end

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        @feed
          .entries
          .joins(feed: :subscriptions)
          .includes(feed: { subscriptions: { taggings: :tag } })
          .merge(Subscription.active)
          .most_recent_first
          .distinct
      end
    end.page(page).per(@pagination_size)
  end

  def show_set_tags_by_subscription
    subscriptions = Subscription.joins(feed: :entries).merge(Entry.where(id: @entry.id))
    subscriptions = subscriptions.where(user_id: current_user.id) if user_signed_in?
    subscription_ids = subscriptions.select(:id)

    @tags_by_subscription = {}.tap do |ret|
      ActsAsTaggableOn::Tagging
        .includes(:tag)
        .where(
          taggable_type: "Subscription",
          taggable_id: subscription_ids
        ).each do |tagging|
        ret[tagging.taggable_id] ||= []
        ret[tagging.taggable_id] << tagging.tag.name.upcase
      end
    end
  end

  def show_set_subscription_by_feed
    @subscription_by_feed = Subscription
      .joins(feed: :entries)
      .merge(
        Entry.where(id: @entry.id)
      )
      .index_by(&:feed_id)
  end
end
