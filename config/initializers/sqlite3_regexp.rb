require_relative "../../lib/extensions/sqlite3_regexp"

ActiveSupport.on_load(:active_record) do
  ActiveRecord::ConnectionAdapters::SQLite3Adapter.include(Extensions::Sqlite3Regexp)
end
