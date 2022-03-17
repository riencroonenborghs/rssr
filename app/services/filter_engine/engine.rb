module FilterEngine
  class Engine < AppService
    attr_reader :user, :scope

    def initialize(user:, scope:) # rubocop:disable Lint/MissingSuper
      @user = user
      @scope = scope
    end

    def call
      return unless user.filter_engine_rules.any?
      return unless or_scope.where_clause.any?

      @scope = scope.where(or_scope.where_clause.ast.not.to_sql).distinct
      @scope = scope.joins(joins_clause) if joins_clause.any?
    end

    private

    def or_scope
      @or_scope ||= begin
        scopes = user.filter_engine_rules.map do |filter_engine_rule|
          filter_engine_rule.chain(Entry)
        end

        scope = scopes.shift
        scopes.each do |other_scope|
          scope = scope.or(other_scope)
        end

        scope
      end
    end

    def joins_clause
      @joins_clause ||= or_scope.joins_values
    end
  end
end
