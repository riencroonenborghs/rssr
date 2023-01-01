class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  delegate :name, :url, :rss_url, :tag_list, :description, to: :feed, allow_nil: true

  validates :feed, uniqueness: { scope: %i[user feed] }

  scope :active, -> { where(active: true) }
  scope :not_hidden_from_main_page, -> { where.not(hide_from_main_page: true) }

  def toggle_active!
    update(active: !active)
  end
end
