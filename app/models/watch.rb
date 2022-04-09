class Watch < ApplicationRecord
  ENTRY_TITLE = "entry_title".freeze
  ENTRY_DESCRIPTION = "entry_description".freeze
  FEED_TAG = "feed_tag".freeze
  WATCH_TYPES = [ENTRY_TITLE, ENTRY_DESCRIPTION, FEED_TAG]

  belongs_to :user

  validates :value, presence: true
  validates :value, uniqueness: { scope: [:watch_type, :user_id] }
  validates :watch_type, inclusion: { in: WATCH_TYPES }

  def tagged?
    watch_type == FEED_TAG
  end

  # def chain(scope)
  #   case watch_type
  #   when ENTRY_TITLE
  #     value.upcase.split(",").map do |title|
  #       scope = entry_title_scope(scope, title)
  #     end
  #   when ENTRY_DESCRIPTION
  #     value.upcase.split(",").map do |description|
  #       scope = entry_description_scope(scope, description)
  #     end
  #   when FEED_TAG
  #     value.upcase.split(",").map do |tag|
  #       scope = feed_tag_scope(scope, tag)
  #     end
  #   end

  #   scope
  # end

  def human_readable
    case watch_type
    when ENTRY_TITLE
      "the title contains #{value.split(",").map(&:upcase).join(' and ')}"
    when ENTRY_DESCRIPTION
      "the description contains #{value.split(",").map(&:upcase).join(' and ')}"
    when FEED_TAG
      "is tagged with #{value.split(",").map(&:upcase).join(' and ')}"
    end
  end

  private

  # def entry_title_scope(scope, title)
  #   scope.where("upper(entries.title) like ?", "%#{title.upcase}%")
  # end

  # def entry_description_scope(scope, description)
  #   scope.where("upper(entries.description) like ?", "%#{description.upcase}%")
  # end

  # def feed_tag_scope(scope, tag)
  #   scope.joins(feed: { taggings: :tags }).merge(Feed.tagged_with(tag.upcase))
  # end
end
