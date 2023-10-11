class TagsController < ApplicationController
  before_action :authenticate_user!

  def index
    @viewed = []
    @cloud = current_user.subscriptions.active.tag_counts_on(:tags)
  end
end
