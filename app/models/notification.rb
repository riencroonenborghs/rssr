# == Schema Information
#
# Table name: notifications
#
#  id             :integer          not null, primary key
#  acked_at       :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  entry_id       :integer          not null
#  user_id        :integer          not null
#  watch_group_id :integer          not null
#
# Indexes
#
#  index_notifications_on_entry_id  (entry_id)
#  index_notifications_on_user_id   (user_id)
#
# Foreign Keys
#
#  entry_id  (entry_id => entries.id)
#  user_id   (user_id => users.id)
#
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :watch_group_id, presence: true

  scope :unacked, -> { where(acked_at: nil) }

  def watches
    user.watches.where(group_id: watch_group_id)
  end
end
