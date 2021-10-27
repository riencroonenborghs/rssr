module FilterEngine
  class FeedRule < Rule
    def chain(scope)
      scope
        .joins(:feed)
        .includes(:feed)
        .where.not("feeds.id #{sql_comparison} ?", value)
    end

    private

    def sql_comparison
      @sql_comparison ||= comparison == "ne" ? "!=" : "="
    end
  end
end