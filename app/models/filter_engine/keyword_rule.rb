module FilterEngine
  class KeywordRule < Rule
    def chain(scope)
      # scope.where("upper(entries.title) #{sql_comparison} ?", "%#{value.upcase}%")

      scopes = where_scopes(scope)
      base_scope = scopes.shift

      scopes.each do |where_scope|
        base_scope = base_scope.or(where_scope)
      end
      base_scope
    end

    def human_readable
      "the title #{human_readable_comparison} #{value.upcase}"
    end

    private

    def where_scopes(scope)
      value.upcase.split(",").map do |part|
        scope.where("upper(entries.title) #{sql_comparison} ?", "%#{part}%")
      end
    end

    def sql_comparison
      @sql_comparison ||= comparison == "ne" ? "not like" : "like"
    end

    def human_readable_comparison
      comparison == "ne" ? "does not contain" : "contains"
    end
  end
end
