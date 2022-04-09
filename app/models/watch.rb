class Watch < ApplicationRecord
  ENTRY_TITLE = "entry_title".freeze
  ENTRY_DESCRIPTION = "entry_description".freeze
  FEED_TAG = "feed_tag".freeze
  WATCH_TYPES = [ENTRY_TITLE, ENTRY_DESCRIPTION, FEED_TAG].freeze

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: %i[watch_type user_id] }
  validates :watch_type, inclusion: { in: WATCH_TYPES }

  def human_readable
    case watch_type
    when ENTRY_TITLE
      "the title contains #{value.split(',').map(&:upcase).join(' and ')}"
    when ENTRY_DESCRIPTION
      "the description contains #{value.split(',').map(&:upcase).join(' and ')}"
    when FEED_TAG
      "is tagged with #{value.split(',').map(&:upcase).join(' and ')}"
    end
  end
end
