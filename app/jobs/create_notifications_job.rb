class CreateNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Watch.all.group_by(&:group_id).each do |_, watches|
      CreateNotifications.perform(watches: watches)
    end
  end
end
