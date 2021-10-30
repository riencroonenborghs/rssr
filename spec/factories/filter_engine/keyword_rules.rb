FactoryBot.define do
  factory :keyword_rule, class: "FilterEngine::KeywordRule" do
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
