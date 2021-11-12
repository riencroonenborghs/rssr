module FilterEngine
  class Engine < AppService
    attr_reader :user, :scope

    def initialize(user:, scope:) # rubocop:disable Lint/MissingSuper
      @user = user
      @scope = scope
    end

    def call
      return unless and_scope_where_clause.any?

      @scope = scope.joins(joins_clauses)
                    .where(and_scope_where_clause.ast.not.to_sql)
                    .distinct
    end

    private

    def joins_clauses
      joins_clauses = and_scope.map(&:joins_values).flatten
      joins = joins_clauses.shift
      joins_clauses.each do |joins_clause|
        joins.update(joins_clause)
      end
      joins
    end

    def and_scope
      scope = Entry
      user.filter_engine_rules.each do |filter_engine_rule|
        scope = filter_engine_rule.chain(scope)
      end
      scope
    end

    def and_scope_where_clause
      @and_scope_where_clause ||= and_scope.where_clause
    end
  end
end
