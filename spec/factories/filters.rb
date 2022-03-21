FactoryBot.define do
  factory :filter do
    user
    eq

    trait :eq do
      comparison { "eq" }
    end
    trait :new do
      comparison { "ne" }
    end
  end
end
