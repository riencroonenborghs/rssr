# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :subscriptions, dependent: :destroy
  has_many :rss_feeds, through: :subscriptions
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_rss_entries, through: :bookmarks, source: :rss_entry
  has_many :filters, dependent: :destroy
  has_many :rss_entry_reads, dependent: :delete_all

  # Subscribing, bookmarking and marking read are idempotent; the unique indexes on the join
  # tables catch duplicates, including concurrent ones.
  def subscribe(rss_feed)
    subscriptions.create_or_find_by!(rss_feed: rss_feed)
  end

  def unsubscribe(rss_feed)
    subscriptions.where(rss_feed: rss_feed).destroy_all
  end

  def subscribed?(rss_feed)
    subscriptions.exists?(rss_feed: rss_feed)
  end

  def bookmark(rss_entry)
    bookmarks.create_or_find_by!(rss_entry: rss_entry)
  end

  def unbookmark(rss_entry)
    bookmarks.where(rss_entry: rss_entry).destroy_all
  end

  def bookmarked?(rss_entry)
    bookmarks.exists?(rss_entry: rss_entry)
  end

  def mark_read(rss_entry)
    rss_entry_reads.create_or_find_by!(rss_entry: rss_entry)
  end

  def read?(rss_entry)
    rss_entry_reads.exists?(rss_entry: rss_entry)
  end
end
