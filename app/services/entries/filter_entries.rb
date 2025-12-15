# frozen_string_literal: true

module Entries
  class FilterEntries
    include Service

    SQLITE3 = "sqlite3"

    attr_reader :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def perform
      service = if ActiveRecord::Base.connection_db_config.adapter == SQLITE3
                  Entries::Filters::Sqlite3Filter.perform(user: @user, scope: @scope)
                else
                  Entries::Filters::PgFilter.perform(user: @user, scope: @scope)
                end
      if service.success?
        @scope = service.scope
        return
      end

      copy_errors(service.errors)
    end
  end
end
