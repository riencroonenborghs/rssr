# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id            :integer          not null, primary key
#  description   :string
#  downloaded_at :datetime
#  guid          :string           not null
#  image         :string
#  link          :string           not null
#  published_at  :datetime         not null
#  title         :string           not null
#  viewed_at     :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  feed_id       :integer          not null
#
# Indexes
#
#  index_entries_on_downloaded_at                (downloaded_at)
#  index_entries_on_feed_id                      (feed_id)
#  index_entries_on_feed_id_and_guid             (feed_id,guid)
#  index_entries_on_guid                         (guid)
#  index_entries_on_published_at                 (published_at)
#  index_entries_on_viewed_at                    (viewed_at)
#  index_entries_on_viewed_at_and_downloaded_at  (viewed_at,downloaded_at)
#
# Foreign Keys
#
#  feed_id  (feed_id => feeds.id)
#
class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_entries, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :tv_entry
  has_one :movie_entry

  acts_as_taggable_on :tags

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }

  attr_accessor :show_entry
end
