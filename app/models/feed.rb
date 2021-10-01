class Feed < ApplicationRecord
  belongs_to :user
  has_many :entries, dependent: :destroy

  validates :url, :title, presence: true
  validates :url, uniqueness: true

  before_validation :guess_title

  scope :alphabetically, -> { order(title: :asc) }
  scope :active, -> { where(active: true) }

  def guess_title
    return if title.present?

    loader = LoadFeed.call(feed: self)
    if loader.failure?
      errors.merge!(loader.errors)
      return
    end

    self.title = loader.loaded_feed.title
  end

  def visit!
    return unless active?
    
    LoadEntries.call(feed: self)
    self.update!(last_visited: Time.zone.now)
  end
  handle_asynchronously :visit!
end
