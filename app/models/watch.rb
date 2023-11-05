# frozen_string_literal: true

class Watch < ApplicationRecord
  ENTRY_TITLE = "entry_title"
  ENTRY_DESCRIPTION = "entry_description"
  FEED_TAG = "feed_tag"
  WATCH_TYPES = [ENTRY_TITLE, ENTRY_DESCRIPTION, FEED_TAG].freeze

  belongs_to :user

  validates :value, presence: true
  validates :watch_type, inclusion: { in: WATCH_TYPES }

  def tagged?
    watch_type == FEED_TAG
  end

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
