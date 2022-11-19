class SubscriptionsController < ApplicationController
  def today
    set_entries_by_tag(timespan: :today)
    set_tags
    set_paged_entries_by_tag
    set_bookmarks
    set_viewed
  end

  def yesterday
    set_entries_by_tag(timespan: :yesterday)
    set_tags
    set_paged_entries_by_tag
    set_bookmarks
    set_viewed
  end

  private

  def set_entries_by_tag(timespan:) # rubocop:disable Naming/AccessorMethodName
    scope = offset_scope do
      filtered_scope do
        scope = Entry
                .most_recent_first
                .send(timespan)
                .joins(feed: { subscriptions: :user })
                .joins(feed: { taggings: :tag })
                .includes(feed: :taggings)
                .merge(Subscription.active.not_hidden_from_main_page)
                .distinct
                .select("ARRAY_AGG(tags.name), entries.*")
                .group("entries.id")
        scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
        scope
      end
    end

    @entries_by_tag = {}.tap do |ret|
      scope.each do |entry|
        entry["array_agg"].each do |tag|
          tag.upcase!
          ret[tag] ||= []
          ret[tag] << entry
        end
      end
    end
  end

  def set_tags
    @tags = @entries_by_tag.keys.sort
  end

  def set_paged_entries_by_tag
    @entries_by_tag = {}.tap do |ret|
      @entries_by_tag.each do |tag, scope|
        ret[tag] = Kaminari.paginate_array(scope).page(1).per(5)
      end
    end
  end
end
