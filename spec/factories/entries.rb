# == Schema Information
#
# Table name: entries
#
#  id           :integer          not null, primary key
#  description  :string
#  image        :string
#  link         :string           not null
#  published_at :datetime         not null
#  title        :string           not null
#  uuid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  feed_id      :integer          not null
#
# Indexes
#
#  index_entries_on_feed_id            (feed_id)
#  index_entries_on_feed_id_and_title  (feed_id,title) UNIQUE
#  index_entries_on_feed_id_and_uuid   (feed_id,uuid)
#  index_entries_on_published_at       (published_at)
#  index_entries_on_searchable         ("searchable")
#  index_entries_on_uuid               (uuid)
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
    published_at { rand(1..10).days.ago }
  end
end
