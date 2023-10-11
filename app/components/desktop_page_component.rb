# frozen_string_literal: true

class DesktopPageComponent < ViewComponent::Base
  with_collection_parameter :entry

  delegate :user_signed_in?, :current_user, :fa_solid, :fa_regular, :cached_bootstrap_tags, to: :helpers

  def initialize(entry:, viewed:, subscription_by_feed:, tags_by_subscription:, bookmarks:, twenty_fours_h_ago:)
    @entry = entry
    @viewed = viewed
    @subscription_by_feed = subscription_by_feed
    @tags_by_subscription = tags_by_subscription
    @bookmarks = bookmarks
    @twenty_fours_h_ago = twenty_fours_h_ago

    @mark_viewed = viewed.include?(entry.id)
    @subscription = subscription_by_feed[entry.feed_id]
    @tags = @subscription ? tags_by_subscription[@subscription.id] : []
  end
end