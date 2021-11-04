class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :feed

  delegate :name, :url, :tag_list, :description, to: :feed, allow_nil: true

  validates :feed, uniqueness: { scope: [:user, :feed] }
end
