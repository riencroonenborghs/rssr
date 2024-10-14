# == Schema Information
#
# Table name: feeds
#
#  id          :integer          not null, primary key
#  active      :boolean          default(TRUE), not null
#  description :text
#  error       :text
#  image_url   :string
#  name        :string           not null
#  refresh_at  :datetime
#  rss_url     :string           not null
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_feeds_on_active      (active)
#  index_feeds_on_refresh_at  (refresh_at)
#  index_feeds_on_url         (url)
#
FactoryBot.define do
  factory :feed do
    sequence :url do |n|
      "http://some.url#{n}.com"
    end
    sequence :rss_url do |n|
      "http://rss.url#{n}.com"
    end

    name { Faker::Lorem.sentence(word_count: 3) }
    active

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
