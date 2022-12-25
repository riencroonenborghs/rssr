# frozen_string_literal: true

class Feed < ApplicationRecord
  RSS = "rss"
  SUBREDDIT = "subreddit"

  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :name, presence: true
  validates :url, url: true
  validates :url, uniqueness: true

  acts_as_taggable_on :tags

  scope :active, -> { where(active: true) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
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
