# frozen_string_literal: true

module ComponentScopeHelpers
  include ScopeHelpers

  delegate :user_signed_in?, :current_user, :page, :paginate, :mobile?, to: :helpers
end
