class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :watch_group_id, presence: true

  scope :unacked, -> { where(acked_at: nil) }

  def watches
    user.watches.where(group_id: watch_group_id)
  end
end
