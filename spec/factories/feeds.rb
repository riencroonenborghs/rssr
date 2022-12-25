FactoryBot.define do
  factory :feed do
    url { Faker::Internet.url }
    name { Faker::Lorem.sentence(word_count: 3) }
    active
    rss

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end

    trait :rss do
      feed_type { "rss" }
    end

    trait :subreddit do
      feed_type { "subreddit" }
    end
  end
end
