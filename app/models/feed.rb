class Feed < ApplicationRecord
  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :name, presence: true
  validates :url, url: true
  validates :url, uniqueness: true

  before_validation :guess_name, if: -> { valid_url? }
  before_validation :guess_image_url, if: -> { valid_url? }

  acts_as_taggable_on :tags

  scope :active, -> { where(active: true) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def guess_name
    return unless url.present?
    return if name.present?

    loader = GetFeedData.perform(feed: self)
    if loader.failure?
      errors.merge!(loader.errors)
      return
    end

    self.name = loader.feed_data&.title
  end

  def guess_image_url # rubocop:disable Metrics/CyclomaticComplexity
    return unless url.present?
    return if image_url.present?
    return if Rails.env.test?

    loader = GetFeedData.perform(feed: self)
    self.image_url = loader.feed_data&.image&.url if loader.success? && loader.feed_data.respond_to?(:image)
  end

  def refresh!
    return unless active?

    update!(error: nil)
    loader = ::CreateEntries.perform(feed: self)
    update!(error: loader.errors.full_messages.to_sentence) if loader.failure?
  rescue StandardError => e
    update!(error: e.message)
  ensure
    update!(refresh_at: Time.zone.now)
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

  def tag_list
    return super unless taggings.loaded?

    taggings.map(&:tag).map(&:name)
  end
end
