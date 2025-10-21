# frozen_string_literal: true

module V2
  class TagsController < V2::BaseController
    def show
      @tag = params[:id]
      @page = params[:page] || 1

      @entries = filtered_scope do
        if current_user
          sub_ids = Subscription.tagged_with(@tag).select(:id)
          scope = Entry.joins(feed: :subscriptions).where(subscriptions: { id: sub_ids, user_id: current_user.id })
          scope.most_recent_first
        else
          Entry.none
        end
      end
      @entries = @entries.page(@page)

      set_subscriptions_by_feed_id(entries_scope: @entries)
      set_viewed_ids(entries_scope: @entries)
      set_bookmarked_ids(entries_scope: @entries)
    end
  end
end
