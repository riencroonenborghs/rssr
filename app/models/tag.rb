# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
class Tag < ApplicationRecord
  validates :name, uniqueness: true
  before_save :uppercase_name

  has_many :taggings

  def uppercase_name
    self.name = name.upcase
  end
end
