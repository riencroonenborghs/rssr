# frozen_string_literal: true

class Entry < ApplicationRecord
  belongs_to :feed
  has_many :viewed_entries, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  acts_as_taggable_on :tags

  validates :guid, :link, :title, :published_at, presence: true

  scope :most_recent_first, -> { order(published_at: :desc) }
  scope :today, -> { most_recent_first.where(published_at: 24.hours.ago..) }
  scope :yesterday, -> { most_recent_first.where(published_at: 48.hours.ago..24.hours.ago) }

  attr_accessor :show_entry

  def self.parse_guid(feedjira_entry)
    guid = feedjira_entry.guid if feedjira_entry.respond_to?(:guid)
    entry_id = feedjira_entry.entry_id if feedjira_entry.respond_to?(:entry_id)
    id = feedjira_entry.id if feedjira_entry.respond_to?(:id)

    guid || entry_id || id
  end

  def bookmarked?(user)
    return false unless user

    bookmarks.where(user_id: user.id).any?
  end
end
