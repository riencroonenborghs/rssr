module FilterEngine
  class TagRule < Rule
    def chain(scope)
      scope
        .joins(feed: { tags: :taggings})
        .includes(feed: { tags: :taggings})
        .where("upper(tags.name) #{sql_comparison} ?", value.upcase)
    end

    def human_readable
      "tag #{sql_comparison} #{value.upcase}"
    end
    
    private

    def sql_comparison
      @sql_comparison ||= comparison == "ne" ? "!=" : "="
    end
  end
end