FactoryBot.define do
  factory :feed do
    user
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence(word_count: 3) }
    active

    trait :active do
      active { true }
    end

    trait :inactive do
      active { false }
    end
  end
end
