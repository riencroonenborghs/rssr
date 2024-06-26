# frozen_string_literal: true

class BookmarkComponent < DesktopEntryComponent
  delegate :user_signed_in?, :mobile?, to: :helpers

  def initialize(entry:, icon_size: 6) # rubocop:disable Lint/MissingSuper
    @entry = entry
    @icon_size = icon_size
  end

  def render?
    user_signed_in?
  end

  def bookmarked?
    @bookmarks.include?(@entry.id)
  end

  def before_render
    set_bookmarks
  end

  private

  def set_bookmarks
    @bookmarks = user_signed_in? ? Bookmark.where(user_id: current_user.id).map(&:entry_id) : []
  end
end
