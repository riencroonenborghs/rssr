FactoryBot.define do
  factory :entry do
    feed
    sequence :link do |n|
      "http://link.url#{n}.com"
    end
    title { Faker::Lorem.sentence(word_count: 3) }
    guid { Faker::Internet.uuid }
  end
end
