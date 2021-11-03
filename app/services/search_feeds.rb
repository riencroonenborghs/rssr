class SearchFeeds < AppService
  attr_reader :user, :query, :page, :feeds

  def initialize(user:, query:, page: 1)
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
      .not_subscribed(user)
      .active
      .alphabetically
  end

  def search
    scope = yield
    return scope unless query.present?

    query_strings = []
    values = []
    
    query.split(" ").map do |value|
      values << Array.new(2, "%#{value.upcase}%")
      query_strings << "(upper(name) like ? OR upper(description) like ?)"
    end
    
    scope.where([query_strings.join(" OR "), values].flatten)
  end

  def paginate
    scope = yield
    scope.page(page)
  end
end