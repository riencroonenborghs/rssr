# frozen_string_literal: true

# == Schema Information
#
# Table name: watches
#
#  id         :integer          not null, primary key
#  value      :string           not null
#  watch_type :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          default(0), not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_watches_on_user_id  (user_id)
#  uniq_watch_combniation    (value,watch_type,user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class Watch < ApplicationRecord
  ENTRY_TITLE = "entry_title"
  ENTRY_DESCRIPTION = "entry_description"
  SUBSCRIPTION_TAG = "subscription_tag"
  ENTRY_TAG = "entry_tag"
  WATCH_TYPES = [ENTRY_TITLE, ENTRY_DESCRIPTION, SUBSCRIPTION_TAG, ENTRY_TAG].freeze

  belongs_to :user

  validates :value, presence: true
  validates :watch_type, inclusion: { in: WATCH_TYPES }

  def human_readable
    case watch_type
    when ENTRY_TITLE
      "the title contains #{value.split(',').map(&:upcase).join(' and ')}"
    when ENTRY_DESCRIPTION
      "the description contains #{value.split(',').map(&:upcase).join(' and ')}"
    when SUBSCRIPTION_TAG
      "subscription is tagged with #{value.split(',').map(&:upcase).join(' and ')}"
    when ENTRY_TAG
      "entry is tagged with #{value.split(',').map(&:upcase).join(' and ')}"
    end
  end
end
