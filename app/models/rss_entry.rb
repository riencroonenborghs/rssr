# == Schema Information
#
# Table name: rss_entries
# Database name: primary
#
#  id           :integer          not null, primary key
#  guid         :string           not null
#  image_url    :string
#  published_at :datetime
#  summary      :text
#  title        :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  rss_feed_id  :integer          not null
#
# Indexes
#
#  index_rss_entries_on_rss_feed_id           (rss_feed_id)
#  index_rss_entries_on_rss_feed_id_and_guid  (rss_feed_id,guid) UNIQUE
#
# Foreign Keys
#
#  rss_feed_id  (rss_feed_id => rss_feeds.id)
#
class RssEntry < ApplicationRecord
  belongs_to :rss_feed
  has_many :bookmarks, dependent: :destroy
  has_many :rss_entry_reads, dependent: :delete_all

  validates :guid, presence: true, uniqueness: { scope: :rss_feed_id }

  scope :unread_by, ->(user) { where.not(id: user.rss_entry_reads.select(:rss_entry_id)) }
  scope :newest_first, -> { order(Arel.sql("COALESCE(rss_entries.published_at, rss_entries.created_at) DESC"), id: :desc) }
end
