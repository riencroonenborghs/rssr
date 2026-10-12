# == Schema Information
#
# Table name: bookmarks
# Database name: primary
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  rss_entry_id :integer          not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_bookmarks_on_rss_entry_id              (rss_entry_id)
#  index_bookmarks_on_user_id                   (user_id)
#  index_bookmarks_on_user_id_and_rss_entry_id  (user_id,rss_entry_id) UNIQUE
#
# Foreign Keys
#
#  rss_entry_id  (rss_entry_id => rss_entries.id)
#  user_id       (user_id => users.id)
#
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :rss_entry
end
