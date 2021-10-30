module FilterEngine
  class DateRule < Rule
    def chain(scope)
      scope.where("entries.published_at #{sql_comparison} ?", value)
    end

    def human_readable
      "published #{sql_comparison} #{value}"
    end

    private

    # rubocop:disable Metrics/MethodLength
    def sql_comparison
      @sql_comparison ||= case comparison
                          # when "eq"
                          #   "="
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
    # rubocop:enable Metrics/MethodLength
  end
end
