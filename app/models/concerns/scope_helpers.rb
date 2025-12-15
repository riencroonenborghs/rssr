# frozen_string_literal: true

module ScopeHelpers
  extend ActiveSupport::Concern

  def filtered_scope
    scope = yield
    return scope unless user_signed_in?

    Entries::FilterEntries.perform(user: current_user, scope: scope).scope
  end

  def user_scope
    scope = yield
    return scope unless user_signed_in?

    scope
      .joins(feed: :subscriptions)
      .where(subscriptions: { user_id: current_user.id })
  end
end