class TagsController < ApplicationController
  before_action :authenticate_user!

  def index
    set_bookmarks
    @viewed = []
    @cloud = current_user.subscriptions.active.tag_counts_on(:tags)
  end
end
