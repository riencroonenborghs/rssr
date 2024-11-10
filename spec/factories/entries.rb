# == Schema Information
#
# Table name: entries
#
#  id            :integer          not null, primary key
#  description   :string
#  downloaded_at :datetime
#  image         :string
#  link          :string           not null
#  published_at  :datetime         not null
#  title         :string           not null
#  uuid          :string           not null
#  viewed_at     :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  feed_id       :integer          not null
#
# Indexes
#
#  index_entries_on_downloaded_at                (downloaded_at)
#  index_entries_on_feed_id                      (feed_id)
#  index_entries_on_feed_id_and_uuid             (feed_id,uuid)
#  index_entries_on_published_at                 (published_at)
#  index_entries_on_uuid                         (uuid)
#  index_entries_on_viewed_at                    (viewed_at)
#  index_entries_on_viewed_at_and_downloaded_at  (viewed_at,downloaded_at)
#
# Foreign Keys
#
#  feed_id  (feed_id => feeds.id)
#
FactoryBot.define do
  factory :entry do
    feed
    sequence :link do |n|
      "http://link.url#{n}.com"
    end
    title { Faker::Lorem.sentence(word_count: 3) }
    uuid { Faker::Internet.uuid }
  end
end
