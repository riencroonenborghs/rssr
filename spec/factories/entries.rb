# == Schema Information
#
# Table name: entries
#
#  id                     :integer          not null, primary key
#  description            :string
#  enclosure_length       :integer
#  enclosure_type         :string
#  enclosure_url          :string
#  guid                   :string           not null
#  image                  :string
#  itunes_author          :string
#  itunes_duration        :string
#  itunes_episode_type    :string
#  itunes_explicit        :boolean
#  itunes_image           :string
#  itunes_summary         :string
#  itunes_title           :string
#  link                   :string           not null
#  media_height           :integer
#  media_thumbnail_height :integer
#  media_thumbnail_url    :string
#  media_thumbnail_width  :integer
#  media_title            :string
#  media_type             :string
#  media_url              :string
#  media_width            :integer
#  published_at           :datetime         not null
#  title                  :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  feed_id                :integer          not null
#
# Indexes
#
#  index_entries_on_feed_id           (feed_id)
#  index_entries_on_feed_id_and_guid  (feed_id,guid)
#  index_entries_on_guid              (guid)
#  index_entries_on_published_at      (published_at)
#  index_entries_on_searchable        ("searchable")
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
    guid { Faker::Internet.uuid }
    published_at { rand(1..10).days.ago }
  end
end
