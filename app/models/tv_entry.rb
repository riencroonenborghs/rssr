# frozen_string_literal: true

# == Schema Information
#
# Table name: tv_entries
#
#  id         :integer          not null, primary key
#  episode    :integer
#  name       :string
#  resolution :string
#  season     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :integer          not null
#
# Indexes
#
#  index_tv_entries_on_entry_id  (entry_id)
#
# Foreign Keys
#
#  entry_id  (entry_id => entries.id)
#
class TvEntry < ApplicationRecord
  belongs_to :entry
end
