class ViewedEntriesController < ApplicationController
  before_action :authenticate_user!

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry

    object = current_user.viewed_entries.build(entry_id: entry.id)
    if object.valid? && object.save
      render json: {success: true, viewed: entry.id}
    else
      render json: {error: object.errors.full_messages.to_sentence}, status: 400
    end
  end
end
