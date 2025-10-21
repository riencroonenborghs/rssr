# frozen_string_literal: true

module V2
  class EntriesController < V2::BaseController
    def show
      @entry = Entry.find_by(id: params[:id])
      @feed = @entry.feed
      
      if current_user
        ViewedEntry.find_or_create_by(user_id: current_user.id, entry_id: @entry.id)
      end

      set_subscriptions_by_feed_id(feed: @feed)
    end
  end
end
