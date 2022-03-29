class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_by, class_name: "ViewedEntry", dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :today, -> { most_recent_first.where(published_at: 24.hours.ago..) }

  def viewed_by?(user)
    viewed_by.where(user_id: user.id).exists?
  end

  def bookmarked?(user)
    bookmarks.where(user_id: user.id, read: nil).exists?
  end

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

  def youtube?
    itemable_type == "YoutubeChannel"
    # xmlns:yt=\"http://www.youtube.com/xml/schemas/2015\"
  end

  def itunes?
    itemable_type == "ItunesPodcast"
  end
end
