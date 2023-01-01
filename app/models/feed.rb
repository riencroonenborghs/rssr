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

  acts_as_taggable_on :tags

  scope :active, -> { where(active: true) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def tag_list
    return super unless persisted? && taggings.loaded?

    taggings.map(&:tag).map(&:name)
  end
end
