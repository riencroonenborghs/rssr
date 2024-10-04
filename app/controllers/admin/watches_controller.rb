# frozen_string_literal: true

module Admin
  class WatchesController < AdminController
    before_action :set_watch, only: %i[update destroy]
    before_action :my_group?, only: %i[add_to_group edit_group remove_group]

    def index
      @grouped_watches = current_user.watches.group_by(&:group_id)
    end

    def show
      base_scope = Entry
        .joins(feed: { subscriptions: :user })
        .includes(feed: { subscriptions: { taggings: :tag } })
        .where("users.id = ?", current_user.id)

      @watches = current_user.watches.where(group_id: params[:group_id])
      @entries = Entries::WatchedEntries.perform(
        watches: @watches,
        scope: base_scope,
        page: page,
        pagination_size: @pagination_size,
        offset: @offset
      ).scope
    end

    def new
      @watch = current_user.watches.build(group_id: next_group_id)
    end

    def create
      @watch = current_user.watches.build(watch_params)

      respond_to do |format|
        if @watch.save
          format.html { redirect_to admin_watches_path, notice: "Watch was added." }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def update
      respond_to do |format|
        if @watch.update(watch_params)
          format.html { redirect_to admin_watches_path, notice: "Watch was updated." }
        else
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @watch.destroy
      respond_to do |format|
        format.html { redirect_to admin_watches_path, notice: "Watch was removed." }
      end
    end

    def add_to_group
      @watch = current_user.watches.build(group_id: params[:group_id])
      @current_watches = current_user.watches.where(group_id: params[:group_id])
    end

    def edit_group
      @watches = current_user.watches.order(watch_type: :asc).where(group_id: params[:group_id])
    end

    def remove_group
      current_user.watches.where(group_id: params[:group_id]).destroy_all

      respond_to do |format|
        format.html { redirect_to admin_watches_path, notice: "Watch group was removed." }
      end
    end
    
    def copy
      watches = current_user.watches.where(group_id: params[:group_id])

      service = CopyWatchGroup.perform(watches: watches)
      respond_to do |format|
        if service.success?
          format.html { redirect_to admin_watches_path, notice: "Watch was copied." }
        else
          format.html { redirect_to admin_watches_path, alert: service.errors.full_messages.to_sentence }
        end
      end
    end

    private

    def next_group_id
      (current_user.watches.order(group_id: :desc).limit(1).first&.group_id || 0) + 1
    end

    def set_watch
      @watch = current_user.watches.find(params[:id])
    end

    def watch_params
      params.require(:watch).permit(:id, :group_id, :watch_type, :value)
    end

    def my_group?
      return true if current_user.watches.exists?(group_id: params[:group_id])

      flash[:alert] = "Not your group"
      redirect_to action: :index
      false
    end
  end
end
