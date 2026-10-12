# Registers SQLite's REGEXP function (`value REGEXP pattern`, used for regexp filters) on every
# connection, backed by Ruby regexps. Patterns are compiled once per connection, and each
# match is bounded by a timeout so a pathological pattern can't hang a query.
module SqliteRegexp
  MATCH_TIMEOUT = 0.1
  MAX_CACHED_PATTERNS = 100

  private
    def configure_connection
      super

      patterns = {}
      raw_connection.create_function("regexp", 2) do |function, pattern, value|
        patterns.clear if patterns.size >= MAX_CACHED_PATTERNS
        regexp = patterns[pattern] ||= Regexp.new(pattern, timeout: MATCH_TIMEOUT)
        function.result = value.present? && regexp.match?(value) ? 1 : 0
      rescue RegexpError, Regexp::TimeoutError
        function.result = 0
      end
    end
end

ActiveSupport.on_load(:active_record_sqlite3adapter) { prepend SqliteRegexp }
