# frozen_string_literal: true

module Api
  module V1
    class UnreadController < Api::BaseController
      def index
        @entries = filtered_scope do
          user_scope do
            Entry.unread(current_user)
          end
        end.page(page)

        set_tags_by_entry
        set_viewed_entries
        set_bookmarks
      end
    end
  end
end
