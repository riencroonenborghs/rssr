# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_entries, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :today, -> { most_recent_first.where(published_at: 24.hours.ago..) }
  scope :yesterday, -> { most_recent_first.where(published_at: 48.hours.ago..24.hours.ago) }

  attr_accessor :show_entry

  def media?
    media_url.present?
  end

  def enclosure?
    enclosure_url.present?
  end

  def enclosure_mp3?
    return false unless enclosure?

    parsed = URI.parse enclosure_url
    parsed.path.split(".")&.last == "mp3"
  end
end
