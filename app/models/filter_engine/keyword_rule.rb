module FilterEngine
  class KeywordRule < Rule
    def chain(scope)
      scope.where("upper(entries.title) #{sql_comparison} ?", "%#{value.upcase}%")
    end

    def human_readable
      "title #{sql_comparison} #{value.upcase}"
    end

    private

    def sql_comparison
      @sql_comparison ||= comparison == "ne" ? "not like" : "like"
    end
  end
end
