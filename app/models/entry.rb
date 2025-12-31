# frozen_string_literal: true

# == Schema Information
#
# Table name: entries
#
#  id           :integer          not null, primary key
#  description  :string
#  image        :string
#  link         :string           not null
#  published_at :datetime         not null
#  title        :string           not null
#  uuid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  feed_id      :integer          not null
#
# Indexes
#
#  index_entries_on_feed_id           (feed_id)
#  index_entries_on_feed_id_and_uuid  (feed_id,uuid)
#  index_entries_on_published_at      (published_at)
#  index_entries_on_searchable        ("searchable")
#  index_entries_on_uuid              (uuid)
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
  after_destroy :remove_entry_title

  validates :uuid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :unread, ->(user) do # rubocop:disable Style/Lambda
    entries = most_recent_first
      .joins(feed: :subscriptions)
      .includes(:feed)
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

  def remove_entry_title
    EntryTitle.where(entry_id: id).destroy_all
  end
end
