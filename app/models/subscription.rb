# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                  :integer          not null, primary key
#  active              :boolean          default(TRUE), not null
#  hide_from_main_page :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  feed_id             :integer          not null
#  user_id             :integer          not null
#
# Indexes
#
#  index_subscriptions_on_active               (active)
#  index_subscriptions_on_feed_id              (feed_id)
#  index_subscriptions_on_hide_from_main_page  (hide_from_main_page)
#  index_subscriptions_on_user_id              (user_id)
#  index_subscriptions_on_user_id_and_feed_id  (user_id,feed_id) UNIQUE
#  sub_u_f_a_hfmp                              (user_id,feed_id,active,hide_from_main_page)
#
# Foreign Keys
#
#  feed_id  (feed_id => feeds.id)
#  user_id  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  delegate :name, :url, :rss_url, :description, to: :feed, allow_nil: true

  validates :feed, uniqueness: { scope: %i[user feed] }

  tagger
  
  scope :active, -> { where(active: true) }
  scope :not_hidden_from_main_page, -> { where.not(hide_from_main_page: true) }

  def toggle_active!
    update(active: !active)
  end

  def tag_list
    return super unless persisted? && taggings.loaded?

    taggings.map(&:tag).map(&:name)
  end
end
