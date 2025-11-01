# frozen_string_literal: true

class EntryComponent < ViewComponent::Base
  delegate :user_signed_in?, :current_user, :sanitize, :mobile?, to: :helpers

  def initialize(entry:) # rubocop:disable Lint/MissingSuper
    @entry = entry
    @entry.show_entry = true

    @sanitized_description = entry.description
    @tags_by_subscription ||= {}
    @subscription_by_feed ||= {}
  end

  def before_render
    show_set_tags_by_subscription
    show_set_subscription_by_feed

    sanitize_description
  end

  private

  def show_set_tags_by_subscription
    subscriptions = Subscription.joins(feed: :entries).merge(Entry.where(id: @entry.id))
    subscriptions = subscriptions.where(user_id: current_user.id) if user_signed_in?
    subscription_ids = subscriptions.select(:id)

    @tags_by_subscription = {}.tap do |ret|
      Tagging
        .includes(:tag)
        .where(
          taggable_type: "Subscription",
          taggable_id: subscription_ids
        ).each do |tagging|
        ret[tagging.taggable_id] ||= []
        ret[tagging.taggable_id] << tagging.tag.name.upcase
      end
    end
  end

  def show_set_subscription_by_feed
    @subscription_by_feed = Subscription
      .joins(feed: :entries)
      .merge(
        Entry.where(id: @entry.id)
      )
      .index_by(&:feed_id)
  end

  # rubocop:disable Style/RedundantRegexpArgument
  # rubocop:disable Style/RedundantRegexpEscape
  def sanitize_description
    return unless @sanitized_description.present?

    @sanitized_description = sanitize(@sanitized_description, tags: %w[strong em p a])
    @sanitized_description = @sanitized_description.gsub(/\<a /, "<a target='_blank' ")
  end
  # rubocop:enable Style/RedundantRegexpArgument
  # rubocop:enable Style/RedundantRegexpEscape
end
