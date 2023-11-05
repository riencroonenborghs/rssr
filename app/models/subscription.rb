# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  delegate :name, :url, :rss_url, :description, to: :feed, allow_nil: true

  validates :feed, uniqueness: { scope: %i[user feed] }

  acts_as_taggable_on :tags

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
