class TagsOnSubscriptions < ActiveRecord::Migration[6.0]
  def change
    ActsAsTaggableOn::Tagging.includes(taggable: :subscriptions).each do |tagging|
      tagging.taggable.subscriptions.each.with_index do |subscription, index|
        if index.zero?
          tagging.update!(taggable_type: "Subscription", taggable_id: subscription.id)
        else
          ActsAsTaggableOn::Tagging.create!(
            taggable_type: "Subscriptions",
            taggable_id: subscription.id,
            tag_id: tagging.tag_id,
            tagger_type: tagging.tagger_type,
            tagger_id: tagging.tagger_id,
            context: tagging.context,
            tenant: tagging.tenant
          )
        end
      end
    end
  end
end
