module FilterEngine
  class Engine < AppService
    attr_reader :user, :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def call
      return unless or_scope

      @scope = scope
        .joins(joins_clauses)
        .where(or_scope.ast.not.to_sql)
        .distinct
    end

    private

    def and_scopes
      @and_scopes ||= user.filter_engine_rules.group_by(&:group_id).map do |_, filter_engine_rules|
        and_scope_for(filter_engine_rules)
      end
    end

    def joins_clauses
      joins_clauses = and_scopes.map(&:joins_values).flatten
      joins = joins_clauses.shift
      joins_clauses.each do |joins_clause|
        joins.update(joins_clause)
      end
      joins
    end

    def and_scope_for(filter_engine_rules)
      scope = Entry
      filter_engine_rules.each do |filter_engine_rule|
        scope = filter_engine_rule.chain(scope)
      end
      scope
    end

    def or_scope
      @or_scope ||= begin
        and_where_clauses = and_scopes.map(&:where_clause)
        scope = and_where_clauses.shift
        and_where_clauses.each do |and_where_clause|
          scope = scope.or(and_where_clause)
        end
        scope
      end
    end
  end
end