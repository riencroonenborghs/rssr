# frozen_string_literal: true

module V2
  class RecentEntriesController < V2::BaseController
    def index
      @page = params[:page] || 1

      @entries = filtered_scope do
        if current_user
          scope = Entry.where(feed_id: current_user.feeds.select(:id))
          scope.most_recent_first.includes(:feed)#.page(@page)
        else
          Entry.most_recent_first.includes(:feed)#.page(@page)
        end
      end
      @entries = @entries.page(@page)
      
      set_subscriptions_by_feed_id(feed_ids: @entries.map(&:feed_id))
      set_viewed_ids(entry_ids: @entries.map(&:id))
      set_bookmarked_ids(entry_ids: @entries.map(&:id))
    end
  end

end
