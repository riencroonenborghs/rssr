# frozen_string_literal: true

# == Schema Information
#
# Table name: viewed_entries
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_viewed_entries_on_entry_id              (entry_id)
#  index_viewed_entries_on_user_id               (user_id)
#  index_viewed_entries_on_user_id_and_entry_id  (user_id,entry_id)
#
# Foreign Keys
#
#  entry_id  (entry_id => entries.id)
#  user_id   (user_id => users.id)
#
class ViewedEntry < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry, uniqueness: { scope: %i[user entry] }
end
