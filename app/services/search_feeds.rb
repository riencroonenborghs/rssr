class SearchFeeds < AppService
  attr_reader :user, :query, :page, :feeds

  def initialize(user:, query:, page: 1) # rubocop:disable Lint/MissingSuper
    @user = user
    @query = query
    @page = page
  end

  def call
    @feeds = paginate do
      search do
        base
      end
    end
  end

  private

  def base
    Feed
      .joins(taggings: :tag)
      .active
      .alphabetically
  end

  def search
    scope = yield
    return scope unless query.present?

    query_strings = []
    values = []

    query.split.map do |value|
      values << Array.new(2, "%#{value.upcase}%")
      query_strings << "(upper(feeds.name) like ? OR upper(feeds.description) like ?)"
    end

    scope.where([query_strings.join(" OR "), values].flatten).or(
      scope.merge(ActsAsTaggableOn::Tag.where("upper(tags.name) = ?", query.upcase))
    ).distinct
  end

  def paginate
    scope = yield
    scope.page(page).per(@pagination_size)
  end
end
