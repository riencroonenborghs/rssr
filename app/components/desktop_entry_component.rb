# frozen_string_literal: true

class DesktopEntryComponent < ViewComponent::Base
  with_collection_parameter :entry

  delegate :user_signed_in?, :current_user, to: :helpers

  def initialize(entry:, viewed:, subscription_by_feed:, tags_by_subscription:) # rubocop:disable Lint/MissingSuper
    @entry = entry
    @viewed = viewed
    @subscription_by_feed = subscription_by_feed
    @tags_by_subscription = tags_by_subscription

    @mark_viewed = viewed.include?(entry.id)
    subscription = subscription_by_feed[entry.feed_id]

    @tags = { subscription: subscription ? tags_by_subscription[subscription.id] : [] }
    @tags[:entry] = @entry.tag_list || []

    @tags[:subscription] = (@tags[:subscription] || []).flatten.map(&:upcase).uniq
    @tags[:entry] = (@tags[:entry] || []).flatten.map(&:upcase).uniq
  end
end
