module Admin
  class FeedsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_feed, only: %i[ edit update destroy visit ]

    def index
      @feeds = current_user.feeds.includes(:entries)
    end

    def new
      @feed = current_user.feeds.new
    end

    def edit
    end

    def create
      @feed = current_user.feeds.new(feed_params)

      respond_to do |format|
        if @feed.save
          format.html { redirect_to admin_feeds_path, notice: "Feed was successfully created." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @feed.update(feed_params)
          format.html { redirect_to admin_feeds_path, notice: "Feed was successfully updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @feed.destroy
      respond_to do |format|
        format.html { redirect_to admin_feeds_url, notice: "Feed was successfully destroyed." }
      end
    end

    def visit
      @feed.visit!
      respond_to do |format|
        format.html { redirect_to admin_feeds_url, notice: "Feed will be visited soon." }
      end
    end

    private

    def set_feed
      @feed = current_user.feeds.find(params[:id])
    end

    def feed_params
      params.require(:feed).permit(:url, :title, :active)
    end
  end
end
