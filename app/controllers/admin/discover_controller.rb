module Admin
  class DiscoverController < AdminController
    before_action :set_page
    before_action :set_tags, only: %i[index]
    before_action :set_query, only: %i[search]

    def search
      @feeds = SearchFeeds.call(user: current_user, query: @query, page: @page).feeds
    end

    def tagged
      @tag = params[:tag]
      @feeds = Feed.tagged_with(@tag).order(name: :asc).page(@page)
    end

    private

    def set_tags
      scope = ActsAsTaggableOn::Tag.most_used(ActsAsTaggableOn::Tag.count)
      if user_signed_in?
        tag_ids = ActsAsTaggableOn::Tagging.where(taggable_type: "Feed").where(taggable_id: current_user.feeds.select(:id).pluck(:id)).select(:tag_id).pluck(:tag_id)
        scope = scope.where(id: tag_ids)
      end

      @tags = Kaminari.paginate_array(scope).page(@page).per(5)
    end

    def set_page
      @page = params[:page]&.to_i || 1
    end

    def set_query
      @query = params[:query]
    end
  end
end
