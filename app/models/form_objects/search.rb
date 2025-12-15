# frozen_string_literal: true

module FormObjects
  class Search < Struct.new(:query, keyword_init: true)
    def self.from_params(search_params)
      new(
        query: search_params[:query]
      )
    end
  end
end
