class RenameFeedTagToSubscriptionTagInWatches < ActiveRecord::Migration[6.1]
  def change
    Watch.where(watch_type: "feed_tag").update_all(watch_type: "subscription_tag")
  end
end
