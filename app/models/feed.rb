class Feed < ApplicationRecord
  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :name, presence: true
  validates :url, uniqueness: true

  before_validation :guess_url
  before_validation :guess_name

  acts_as_taggable_on :tags

  scope :alphabetically, -> { order(name: :asc) }
  scope :active, -> { where(active: true) }
  scope :not_subscribed, -> (user) { where.not(id: user.subscriptions.pluck(:feed_id))  }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def guess_url
    return unless url.match?(/youtube\.com/)
    return if url.match?(/feed/)

    self.url = YoutubeFeedUrl.call(url: url).feed_url
  end

  def guess_name
    return if name.present?

    loader = LoadFeed.call(feed: self)
    if loader.failure?
      errors.merge!(loader.errors)
      return
    end

    self.name = loader.loaded_feed.name
  end

  def visit!
    return unless active?

    loader = LoadEntries.call(feed: self)
    update!(error: loader.errors.full_messages.to_sentence) if loader.failure?
  rescue StandardError => e
    update!(error: e.message)
  ensure
    update!(last_visited: Time.zone.now)
  end
  handle_asynchronously :visit!

  def youtube?
    url.match?(/youtube\.com/)
  end
end
