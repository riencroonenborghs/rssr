# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def ack
    notification = current_user.notifications.where(id: params[:id]).first
    return unless notification
  
    current_user.notifications.where(watch_group_id: notification.watch_group_id).update(acked_at: Time.zone.now)
    render plain: "acked"
  end
end
