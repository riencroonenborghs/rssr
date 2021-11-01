FactoryBot.define do
  factory :feed do
    url { Faker::Internet.url }
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
