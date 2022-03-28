class Feed < ApplicationRecord
  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :name, presence: true
  validates :url, url: true
  validates :url, uniqueness: true

  before_validation :guess_url, if: -> { valid_url? }
  before_validation :guess_name, if: -> { valid_url? }
  before_validation :guess_image_url, if: -> { valid_url? }

  acts_as_taggable_on :tags

  scope :active, -> { where(active: true) }

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

  def guess_image_url # rubocop:disable Metrics/CyclomaticComplexity
    return unless url.present?
    return if image_url.present?
    return if Rails.env.test?

    loader = LoadFeed.call(feed: self)
    self.image_url = loader.loaded_feed&.image&.url if loader.success? && loader.loaded_feed.respond_to?(:image)
  end

  def sync!
    return unless active?

    update!(error: nil)
    loader = ::CreateEntriesService.call(feed: self)
    update!(error: loader.errors.full_messages.to_sentence) if loader.failure?
  rescue StandardError => e
    update!(error: e.message)
  ensure
    update!(last_visited: Time.zone.now)
  end

  def youtube?
    url.match?(/youtube\.com/)
  end

  def valid_url?
    validator = ActiveModel::Validations::UrlValidator.new({ attributes: [1] })
    feed = self.class.new
    validator.validate_each(feed, :url, url)
    !feed.errors[:url].present?
  end

  def valid_image_url?
    image_url.present? && !image_url.starts_with?("..")
  end
end
