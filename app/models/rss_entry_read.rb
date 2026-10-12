# Records that a user has read an entry.
# == Schema Information
#
# Table name: rss_entry_reads
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
#  index_rss_entry_reads_on_rss_entry_id              (rss_entry_id)
#  index_rss_entry_reads_on_user_id                   (user_id)
#  index_rss_entry_reads_on_user_id_and_rss_entry_id  (user_id,rss_entry_id) UNIQUE
#
# Foreign Keys
#
#  rss_entry_id  (rss_entry_id => rss_entries.id) ON DELETE => cascade
#  user_id       (user_id => users.id)
#
class RssEntryRead < ApplicationRecord
  belongs_to :user
  belongs_to :rss_entry
end
