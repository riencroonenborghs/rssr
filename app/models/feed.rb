class Feed < ApplicationRecord
  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :name, presence: true
  validates :url, url: true
  validates :url, uniqueness: true

  before_validation :guess_url, if: -> { valid_url? }
  before_validation :guess_name, if: -> { valid_url? }

  acts_as_taggable_on :tags

  scope :alphabetically, -> { order(name: :asc) }
  scope :active, -> { where(active: true) }
  scope :not_subscribed, ->(user) { where.not(id: user.subscriptions.pluck(:feed_id)) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def guess_url
    return unless url.present?
    return unless url.match?(/youtube\.com/)
    return if url.match?(/feed/)

    self.url = YoutubeFeedUrl.call(url: url).feed_url
  end

  def guess_name
    return unless url.present?
    return if name.present?

    loader = LoadFeed.call(feed: self)
    if loader.failure?
      errors.merge!(loader.errors)
      return
    end

    self.name = loader.loaded_feed&.title
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

  def valid_url?
    validator = ActiveModel::Validations::UrlValidator.new({ attributes: [1] })
    feed = self.class.new
    validator.validate_each(feed, :url, url)
    !feed.errors[:url].present?
  end
end
