# frozen_string_literal: true

module Entries
  class FilterEntries
    include Base

    attr_reader :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def perform
      service = if ActiveRecord::Base.connection_db_config.adapter == "sqlite3"
                  Entries::Filters::Sqlite3Filter.perform(user: @user, scope: @scope)
                else
                  Entries::Filters::PgFilter.perform(user: @user, scope: @scope)
                end
      if service.success?
        @scope = service.scope
        return
      end

      merge_errors(service.errors)
    end
  end
end
