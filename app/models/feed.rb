class Feed < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :destroy

  validates :url, :title, presence: true
  validates :url, uniqueness: true

  before_validation :guess_url
  before_validation :guess_title

  acts_as_taggable_on :tags

  scope :alphabetically, -> { order(title: :asc) }
  scope :active, -> { where(active: true) }

  def guess_url
    return unless url.match?(/youtube\.com/)
    return if url.match?(/feed/)

    self.url = YoutubeFeedUrl.call(url: url).feed_url
  end

  def guess_title
    return if title.present?

    loader = LoadFeed.call(feed: self)
    if loader.failure?
      errors.merge!(loader.errors)
      return
    end

    self.title = loader.loaded_feed.title
  end

  def visit!
    return unless active?
    
    LoadEntries.call(feed: self)
    self.update!(last_visited: Time.zone.now)
  end
  handle_asynchronously :visit!

  def youtube?
    url.match?(/youtube\.com/)
  end
end
