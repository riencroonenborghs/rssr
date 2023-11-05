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
