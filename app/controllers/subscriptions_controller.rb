class SubscriptionsController < ApplicationController
  def today
    set_entries_by_tag(timespan: :today)
    set_tags
    set_bookmarks
    set_viewed
  end

  def yesterday
    set_entries_by_tag(timespan: :yesterday)
    set_tags
    set_bookmarks
    set_viewed
  end

  private

  def set_entries_by_tag(timespan:)
    all_tags = Feed.tag_counts_on(:tags).map(&:name).map(&:upcase).sort
    @entries_by_tag = {}.tap do |ret|
      all_tags.each do |tag|
        ret[tag] = offset_scope do
          filtered_scope do
            scope = Entry
                    .includes(:viewed_entries)
                    .most_recent_first
                    .send(timespan)
                    .joins(feed: { subscriptions: :user })
                    .merge(Subscription.active.not_hidden_from_main_page)
                    .merge(Feed.tagged_with(tag))
                    .distinct
            scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
            scope
          end.page(1).per(10)
        end
      end
    end
  end

  def set_tags
    @tags = @entries_by_tag.select { |tag, entries| !entries.count.zero? }.keys
  end
end
