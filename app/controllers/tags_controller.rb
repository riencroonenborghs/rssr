class TagsController < ApplicationController
  before_action :authenticate_user!

  def index
    set_bookmarks
    @viewed = []
    # @tags = ActsAsTaggableOn::Tag.where(id:
    #   ActsAsTaggableOn::Tagging.where(
    #     taggable_type: "Subscription",
    #     taggable_id: current_user.subscriptions.active.map(&:id)
    #   ).map(&:tag_id)
    # ).map(&:name).sort.map(&:upcase)
    @cloud = current_user.subscriptions.active.tag_counts_on(:tags)
  end
end
