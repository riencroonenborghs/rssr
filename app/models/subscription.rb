# == Schema Information
#
# Table name: subscriptions
# Database name: primary
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rss_feed_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_subscriptions_on_rss_feed_id              (rss_feed_id)
#  index_subscriptions_on_user_id                  (user_id)
#  index_subscriptions_on_user_id_and_rss_feed_id  (user_id,rss_feed_id) UNIQUE
#
# Foreign Keys
#
#  rss_feed_id  (rss_feed_id => rss_feeds.id)
#  user_id      (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :rss_feed
end
