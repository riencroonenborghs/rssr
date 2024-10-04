# frozen_string_literal: true

class CopyWatchGroup
  include Base

  def initialize(watches:)
    @watches = watches
    @user = watches.first.user
  end

  def perform
    Watch.transaction do
      @watches.each do |watch|
        copy_watch(watch: watch)
        ActiveRecord::Rollback if failure?
      end
    end
  end

  private

  def next_group_id
    @next_group_id ||= (@user.watches.order(group_id: :desc).limit(1).first&.group_id || 0) + 1
  end

  def copy_watch(watch:)
    attrs = watch.attributes
    new_watch = @user.watches.build(
      watch_type: attrs["watch_type"],
      value: "#{attrs["value"]} (copy)",
      group_id: next_group_id
    )
    return if new_watch.save

    errors(:base, "Could not copy watch #{attrs["value"]}")
  end
end
