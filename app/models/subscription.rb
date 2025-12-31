# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer          not null, primary key
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  feed_id    :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_subscriptions_on_active               (active)
#  index_subscriptions_on_feed_id              (feed_id)
#  index_subscriptions_on_user_id              (user_id)
#  index_subscriptions_on_user_id_and_feed_id  (user_id,feed_id) UNIQUE
#  sub_u_f_a_hfmp                              (user_id,feed_id,active)
#
# Foreign Keys
#
#  feed_id  (feed_id => feeds.id)
#  user_id  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  delegate :title, :url, :description, to: :feed, allow_nil: true

  validates :feed, uniqueness: { scope: %i[user feed] }

  tagged
  
  scope :active, -> { where(active: true) }

  # Form
  attr_accessor :get_title_from_url, :tag_names

  def toggle_active!
    update(active: !active)
  end
end
