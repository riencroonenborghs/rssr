# frozen_string_literal: true

# == Schema Information
#
# Table name: movie_entries
#
#  id         :integer          not null, primary key
#  cam        :boolean
#  name       :string
#  resolution :string
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :integer          not null
#
# Indexes
#
#  index_movie_entries_on_entry_id  (entry_id)
#
# Foreign Keys
#
#  entry_id  (entry_id => entries.id)
#
class MovieEntry < ApplicationRecord
  belongs_to :entry
end
