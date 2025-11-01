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
FactoryBot.define do
  factory :viewed_entry do
    user { nil }
    entry { nil }
  end
end
