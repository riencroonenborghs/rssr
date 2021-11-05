class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_by, class_name: "ViewedEntry"
  has_many :read_later, class_name: "ReadLaterEntry"

  validates :entry_id, :url, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :today, -> { most_recent_first.where(published_at: 24.hours.ago..) }

  def viewed_by?(user)
    viewed_by.where(user_id: user.id).exists?
  end

  def read_it?(user)
    read_later.where(user_id: user.id).exists?
  end
end
