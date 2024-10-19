# frozen_string_literal: true

class FilterEntries
  include Base

  attr_reader :user, :scope

  def initialize(user:, scope:)
    @user = user
    @scope = scope
  end

  def perform
    service = if ActiveRecord::Base.connection_db_config.adapter == "sqlite3"
                ::Filters::Sqlite3FilterEntries.perform(user: user, scope: scope)
              else
                ::Filters::PgFilterEntries.perform(user: user, scope: scope)
              end

    return @scope = service.scope if service.success?

    errors.merge!(service.errors)
  end
end
