class Entry < ApplicationRecord
  belongs_to :feed

  validates :entry_id, :url, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :last_24h, -> { most_recent_first.where(published_at: 24.hours.ago..) }
end
