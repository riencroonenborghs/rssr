class ReadLaterEntry < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry, uniqueness: { scope: %i[user entry] }

  scope :unread, -> { where(read: nil) }

  def read!
    return if read.present?

    update!(read: Time.current)
  end
end
