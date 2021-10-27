FactoryBot.define do
  factory :entry do
    feed
    url { Faker::Internet.url }
    title { Faker::Lorem.sentence(word_count: 3) }
    entry_id { Faker::Internet.uuid }
  end
end
