# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id                     :integer          not null, primary key
#  description            :string
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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  feed_id                :integer          not null
#
# Indexes
#
#  index_entries_on_feed_id           (feed_id)
#  index_entries_on_feed_id_and_guid  (feed_id,guid)
#  index_entries_on_guid              (guid)
#  index_entries_on_published_at      (published_at)
#  index_entries_on_searchable        ("searchable")
#
# Foreign Keys
#
#  feed_id  (feed_id => feeds.id)
#
class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_entries, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  tagged

  after_save :create_or_update_entry_title

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :unread, ->(user) do
    entries = most_recent_first
      .joins(feed: :subscriptions)
      .includes(:feed)
      .merge(Subscription.active.not_hidden_from_main_page)      
      .distinct
    return entries unless user

    entries.where.not(id: ViewedEntry.where(user_id: user.id).select(:entry_id))
  end

  attr_accessor :show_entry

  def bookmarked?(user)
    return false unless user

    bookmarks.where(user_id: user.id).any?
  end

  def create_or_update_entry_title
    EntryTitle.find_or_create_by(entry_id: id, title: title)
  end
end
