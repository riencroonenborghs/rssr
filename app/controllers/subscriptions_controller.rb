class SubscriptionsController < ApplicationController
  def today
    set_entries(timespan: :today)
    set_tags_by_subscription
    set_subscription_by_feed
    set_tags
    set_bookmarks
    set_viewed

    return paged_render if params.key?(:page)
  end

  def yesterday
    set_entries(timespan: :yesterday)
    set_tags_by_subscription
    set_subscription_by_feed
    set_tags
    set_bookmarks
    set_viewed

    return paged_render if params.key?(:page)
  end

  private

  def set_entries(timespan:)
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
          .most_recent_first
          .send(timespan)
          .joins(feed: { subscriptions: :user })
          .joins(feed: { subscriptions: { taggings: :tag } })
          .includes(feed: { subscriptions: { taggings: :tag } })
          .merge(Subscription.active.not_hidden_from_main_page)

        if user_signed_in?
          scope = scope
            .where(feed_id: 
              Feed.where(id: 
                Subscription.where(user_id: current_user.id)
                  .select(:feed_id)
              ).select(:id)
            )
        end

        scope.distinct
      end
    end.page(page).per(@pagination_size)
  end

  def set_tags
    return @tags = [] unless user_signed_in?

    @tags = ActsAsTaggableOn::Tag.where(id: 
      ActsAsTaggableOn::Tagging.where(taggable_type: "Subscription", taggable_id: 
        Subscription.active.where(user_id: current_user.id).select(&:id)
      ).select(:tag_id)
    ).distinct(:name).pluck(:name).sort.map(&:upcase)
  end
end
