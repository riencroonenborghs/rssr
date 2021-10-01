class Entry < ApplicationRecord
  belongs_to :feed

  validates :entry_id, :url, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
end
