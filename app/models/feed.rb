# frozen_string_literal: true

# == Schema Information
#
# Table name: feeds
#
#  id          :integer          not null, primary key
#  active      :boolean          default(TRUE), not null
#  description :text
#  error       :text
#  image_url   :string
#  name        :string           not null
#  refresh_at  :datetime
#  rss_url     :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_feeds_on_active      (active)
#  index_feeds_on_refresh_at  (refresh_at)
#  index_feeds_on_url         (url)
#
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
  scope :by_name, -> { order(name: :asc) }
  scope :no_error, -> { where(error: nil) }

  def subscribed?(user)
    subscriptions.where(user_id: user.id).exists?
  end

  def subscription_for(user)
    return Subscription.new unless user

    subscriptions.find_by(user_id: user.id)
  end

  def self.random(user:, limit: 8)
    user.feeds.order("RANDOM()").limit(limit)
  end

  def self.most_read(limit: 8)
    last_2_weeks = (2.weeks.ago.beginning_of_week.beginning_of_day..)
    feed_id_by_count = Entry.where(id: ViewedEntry.where(created_at: last_2_weeks).select(:entry_id)).select(:feed_id).group(:feed_id).count
    return Feed.none if feed_id_by_count.empty?

    feed_id_by_count_sorted = feed_id_by_count.sort do |a, b|
      a_id, a_count = a
      b_id, b_count = b
      b_count <=> a_count
    end
    sorted_feed_ids = feed_id_by_count_sorted.map(&:first)
    cased_order = sorted_feed_ids.map.with_index { |x, index| "WHEN ID = #{x} THEN #{index+1}" }.join(" ")
    order_by = "CASE #{cased_order} END"
    order(Arel.sql(order_by)).limit(limit)
  end
end
