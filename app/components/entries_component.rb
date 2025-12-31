# frozen_string_literal: true

class EntriesComponent < ViewComponent::Base
  include ComponentScopeHelpers

  def initialize(entries: nil) # rubocop:disable Lint/MissingSuper
    @entries = entries
    @viewed_entries = {}
    @bookmarks = {}
  end

  def before_render
    set_entries
    set_tags_by_entry
    set_viewed_entries
    set_bookmarks
  end

  private

  def set_entries
    @entries ||= filtered_scope do # rubocop:disable Naming/MemoizedInstanceVariableName
      user_scope do
        Entry.unread(current_user)
      end
    end.page(page)
  end

  def set_tags_by_entry # rubocop:disable Metrics/PerceivedComplexity
    @tags_by_entry = {}.tap do |ret|
      if user_signed_in?
        @entries.group_by(&:feed_id).each do |feed_id, list|
          subscription = current_user.subscriptions.find_by(feed_id: feed_id)
          subscription.tags.each do |tag|
            list.each do |entry|
              ret[entry.id] ||= []
              ret[entry.id] << tag
            end
          end
        end
      end

      Tagging
        .includes(:tag)
        .where(
          taggable_type: "Entry",
          taggable_id: @entries.select(:id)
        ).each do |tagging|
        ret[tagging.taggable_id] ||= []
        ret[tagging.taggable_id] << tagging.tag
      end
    end
  end

  def set_viewed_entries
    return unless user_signed_in?

    @viewed_entries = current_user.viewed_entries.where(entry_id: @entries.map(&:id)).index_by(&:entry_id)
  end

  def set_bookmarks
    return unless user_signed_in?

    @bookmarks = current_user.bookmarks.where(entry_id: @entries.map(&:id)).index_by(&:entry_id)
  end
end
