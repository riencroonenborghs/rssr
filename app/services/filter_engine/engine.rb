module FilterEngine
  class Engine < AppService
    attr_reader :user, :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def call
      # @entries = Entry
      #   .joins(feed: :user)
      #   .where("users.id = ?", user.id)
      # @entries = entries.merge(or_scope) if or_scope

      @scope = scope.merge(or_scope) if or_scope
    end

    private

    def chained_and_scopes
      @and_scopes ||= user.filter_engine_rules.group_by(&:group_id).map do |_, filter_engine_rules|
        chain_and_scope(filter_engine_rules)
      end
    end

    def chain_and_scope(filter_engine_rules)
      scope = Entry
      filter_engine_rules.each do |filter_engine_rule|
        scope = filter_engine_rule.chain(scope)
      end
      scope
    end

    def or_scope
      @or_scope ||= begin
        scope = chained_and_scopes.shift
        chained_and_scopes.each do |chained_and_scope|
          scope = scope.or(chained_and_scope)
        end
        scope
      end
    end
  end
end