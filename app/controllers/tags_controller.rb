class TagsController < ApplicationController
  def index
    @tags = Feed.tag_counts_on(:tags).sort_by { |tag| tag.name.upcase }
  end
end
