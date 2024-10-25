# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id                     :integer          not null, primary key
#  description            :string
#  downloaded_at          :datetime
#  enclosure_length       :integer
#  enclosure_type         :string
#  enclosure_url          :string
#  guid                   :string           not null
#  image                  :string
#  itunes_author          :string
#  itunes_duration        :string
#  itunes_episode_type    :string
#  itunes_explicit        :boolean
#  itunes_image           :string
#  itunes_summary         :string
#  itunes_title           :string
#  link                   :string           not null
#  media_height           :integer
#  media_thumbnail_height :integer
#  media_thumbnail_url    :string
#  media_thumbnail_width  :integer
#  media_title            :string
#  media_type             :string
#  media_url              :string
#  media_width            :integer
#  published_at           :datetime         not null
#  title                  :string           not null
#  viewed_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  feed_id                :integer          not null
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

  acts_as_taggable_on :tags

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }

  attr_accessor :show_entry

  def media?
    media_url.present?
  end

  def enclosure?
    enclosure_url.present?
  end

  def enclosure_mp3?
    return false unless enclosure?

    parsed = URI.parse enclosure_url
    parsed.path.split(".")&.last == "mp3"
  end
end
