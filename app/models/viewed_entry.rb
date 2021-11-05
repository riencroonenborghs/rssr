class ViewedEntry < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry, uniqueness: { scope: [:user, :entry] }
end
