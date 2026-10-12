# == Schema Information
#
# Table name: rss_feeds
# Database name: primary
#
#  id              :integer          not null, primary key
#  active          :boolean          default(TRUE), not null
#  error           :string
#  last_fetched_at :datetime
#  title           :string
#  url             :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_rss_feeds_on_url  (url) UNIQUE
#
class RssFeed < ApplicationRecord
  has_many :rss_entries, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :users, through: :subscriptions

  normalizes :url, with: ->(url) { url.strip }
  normalizes :title, with: ->(title) { title.strip.presence }

  validates :url, presence: true, uniqueness: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must start with http:// or https://" },
                  allow_blank: true

  scope :active, -> { where(active: true) }
  scope :by_title, -> { order(Arel.sql("LOWER(COALESCE(NULLIF(rss_feeds.title, ''), rss_feeds.url))")) }

  def display_title
    title.presence || url
  end
end
