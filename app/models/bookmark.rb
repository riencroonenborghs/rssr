# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmarks
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  entry_id   :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_bookmarks_on_entry_id              (entry_id)
#  index_bookmarks_on_user_id               (user_id)
#  index_bookmarks_on_user_id_and_entry_id  (user_id,entry_id)
#  readltr_usr_entry_rd                     (user_id,entry_id)
#
# Foreign Keys
#
#  entry_id  (entry_id => entries.id)
#  user_id   (user_id => users.id)
#
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :entry

  validates :entry, uniqueness: { scope: %i[user entry] }
end
