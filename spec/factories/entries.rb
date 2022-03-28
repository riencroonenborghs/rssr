FactoryBot.define do
  factory :entry do
    feed
    link { Faker::Internet.url }
    title { Faker::Lorem.sentence(word_count: 3) }
    guid { Faker::Internet.uuid }
  end
end
