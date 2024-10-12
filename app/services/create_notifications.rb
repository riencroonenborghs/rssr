# frozen_string_literal: true

class CreateNotifications
  include Base

  def initialize(watches:)
    @watches = watches
    @watch_group_id = watches.first.group_id
    @user = watches.first.user
  end

  def perform
    find_entries
    find_existing_entry_ids
    
    new_entry_ids = @entries.pluck(:id) - @existing_entry_ids

    Notification.transaction do
      @entries.each do |entry|
        next unless new_entry_ids.include?(entry.id)

        @user.notifications.create!(
          watch_group_id: @watch_group_id,
          entry_id: entry.id
        )
      end
    end
  end

  private

  def find_entries
    scope = Entry
      .joins(feed: { subscriptions: :user })
      .includes(feed: { subscriptions: { taggings: :tag } })
      .where("users.id = ?", @user.id)

    @entries = FindWatchedEntries.perform(
      watches: @watches,
      scope: scope
    ).scope
  end

  def find_existing_entry_ids
    @existing_entry_ids = @user.notifications.where(
      entry_id: @entries.pluck(:id),
      watch_group_id: @watch_group_id
    ).pluck(:entry_id)
  end
end