# frozen_string_literal: true

class ViewedEntry < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry, uniqueness: { scope: %i[user entry] }
end
