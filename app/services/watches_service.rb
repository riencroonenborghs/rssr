class WatchesService
  include AppService

  attr_reader :user, :scope

  def initialize(user:, scope:)
    @user = user
    @scope = scope
  end

  def call
    return unless user.filters.any?

    @scope = Entry.filter(filter_terms).merge(scope)
  end

  private

  def filter_terms
    user.filters.map do |filter|
      case filter.comparison
      when "eq"
        filter.value
      when "ne"
        "!#{filter.value}"
      end
    end.join(" ")
  end
end
