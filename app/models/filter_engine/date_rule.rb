module FilterEngine
  class DateRule < Rule
    def chain(scope)
      scope.where("entries.published_at #{sql_comparison} ?", value)
    end

    def human_readable
      "published #{sql_comparison} #{value}"
    end

    private

    def sql_comparison
      @sql_comparison ||= begin
        case comparison
        when "eq"
          "="
        when "ne"
          "!="
        when "lt"
          "<"
        when "lte"
          "<="
        when "gt"
          ">"
        when "gte"
          ">="
        else
          "="
        end
      end
    end
  end
end