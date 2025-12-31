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
#  refresh_at  :datetime
#  title       :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_feeds_on_active      (active)
#  index_feeds_on_refresh_at  (refresh_at)
#  index_feeds_on_url         (url) UNIQUE
#
class Feed < ApplicationRecord
  has_many :subscriptions, foreign_key: :feed_id
  has_many :users, through: :subscriptions

  has_many :entries, dependent: :destroy

  validates :url, :title, presence: true
  validates :url, url: true
  validates :url, uniqueness: true
end
