# frozen_string_literal: true

class SearchesController < ApplicationController
  def results
    set_watches

    @entries = Entries::WatchedEntries.perform(
      scope: base_scope,
      watches: @watches,
      page: params[:page] || 1
    ).scope
  end

  private

  def set_watches
    @watches ||= begin # rubocop:disable Naming/MemoizedInstanceVariableName
      watch_types = params[:search][:watch_type]
      values = params[:search][:value]

      watches = watch_types.map.with_index do |watch_type, index|
        # remove template
        next if index.zero?

        Watch.new(watch_type: watch_type, value: values[index])
      end
      watches.compact!
    end
  end

  def base_scope
    @base_scope ||= begin
      scope = Entry
        .joins(feed: { subscriptions: :user })
        .includes(feed: { subscriptions: { taggings: :tag } })
      scope = scope.where("users.id = ?", current_user.id) if user_signed_in?
      scope
    end
  end
end
