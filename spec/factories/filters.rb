# == Schema Information
#
# Table name: filters
#
#  id         :integer          not null, primary key
#  comparison :string           default("eq"), not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  filter_val_usr_type       (value,user_id)
#  index_filters_on_user_id  (user_id)
#  uniq_filter_val_usr_type  (value,user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
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
