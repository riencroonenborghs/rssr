# frozen_string_literal: true

class Feed < ApplicationRecord
  RSS = "rss"
  SUBREDDIT = "subreddit"

  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :rss_url, :name, presence: true
  validates :url, url: true
  validates :rss_url, url: true
  validates :url, uniqueness: true
  validates :rss_url, uniqueness: true

  scope :active, -> { where(active: true) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def subscription_for(user)
    return Subscription.new unless user

    subscriptions.find_by(user_id: user.id)
  end
end
