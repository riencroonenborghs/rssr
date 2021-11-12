module FilterEngine
  class KeywordRule < Rule
    def chain(scope)
      value.upcase.split(",").map do |part|
        scope = scope.where("upper(entries.title) #{sql_comparison} ?", "%#{part}%")
      end

      scope
    end

    def human_readable
      "the title #{human_readable_comparison} #{value.upcase}"
    end

    private

    def sql_comparison
      @sql_comparison ||= comparison == "ne" ? "not like" : "like"
    end

    def human_readable_comparison
      comparison == "ne" ? "does not contain" : "contains"
    end
  end
end
