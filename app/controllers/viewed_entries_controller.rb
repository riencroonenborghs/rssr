# frozen_string_literal: true

class ViewedEntriesController < ApplicationController
  before_action :authenticate_user!

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry
    return if entry.viewed_at.present?

    if entry.update(viewed_at: Time.zone.now)
      render json: { success: true }
    else
      render json: { error: entry.errors.full_messages.to_sentence }, status: 400
    end
  end
end
