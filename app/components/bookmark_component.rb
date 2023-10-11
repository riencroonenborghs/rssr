# frozen_string_literal: true

class BookmarkComponent < DesktopPageComponent
  delegate :user_signed_in?, to: :helpers

  def initialize(entry:) # rubocop:disable Lint/MissingSuper
    @entry = entry
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
    @bookmarks = user_signed_in? ? Bookmark.unread.where(user_id: current_user.id).map(&:entry_id) : []
  end
end
