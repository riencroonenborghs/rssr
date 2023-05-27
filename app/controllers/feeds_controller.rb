class FeedsController < ApplicationController
  before_action :authenticate_user!, only: [:index]

  def index
    set_bookmarks
    @viewed = []
    @feeds = Feed.where(id: current_user.subscriptions.active.select(:feed_id)).order(name: :desc)
    
    # subscriptions for this user and the found feeds
    scope = Subscription
      .where(user_id: current_user.id)
      .joins(:feed)
      .merge(
        Feed.where(id: @feeds.select(&:id))
      )

    # { feed_id => Subscription, feed_id => Subscription }
    @subscription_by_feed = scope.index_by(&:feed_id)
      
    # { feed_id => subscription_id, feed_id => subscription_id }
    feed_id_by_subscription_id = scope
      .select(:id, :feed_id)
      .index_by(&:feed_id)
      .invert
      .transform_keys{ |key| key.id }
    
    # { feed_id => [tag, tag], feed_id => [tag, tag] }
    @tags_by_feed = {}.tap do |ret|
      ActsAsTaggableOn::Tagging
        .includes(:tag)
        .where(
          taggable_type: "Subscription",
          taggable_id: Subscription
            .where(user_id: current_user.id)
            .joins(:feed)
            .merge(
              Feed.where(id: @feeds.select(&:id))
            )
        )
        .each do |tagging|
          feed_id = feed_id_by_subscription_id[tagging.taggable_id]
          ret[feed_id] ||= []
          ret[feed_id] << tagging.tag.name.upcase
        end
    end
  end
  
  def tagged
    set_tag
    set_entries
    set_tags_by_subscription
    set_subscription_by_feed
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_tag
    @tag = params[:tag]&.upcase
  end

  def set_entries
    scope = filtered_scope do
      current_user_scope do
        Entry
          .includes(feed: { subscriptions: { taggings: :tag } })
          .merge(Subscription.active.tagged_with(@tag))
          .joins(feed: { subscriptions: :taggings })
          .most_recent_first
          .distinct
      end
    end
    @entries = scope.page(page).per(@pagination_size)
  end
end
