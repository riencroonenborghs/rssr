class FilterService
  include AppService

  attr_reader :user, :scope

  def initialize(user:, scope:)
    @user = user
    @scope = scope
  end

  def call
    return unless user.filters.any?

    generate_filters
    @scope = scope.where.not("upper(entries.title) like any (array[#{filters}])")
  end

  private

  attr_reader :filters

  def generate_filters
    @filters = user.filters.map(&:value).map { |v| "'%#{v.upcase}%'" }.join(", ")
  end
end
