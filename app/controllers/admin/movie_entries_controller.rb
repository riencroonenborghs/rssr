# frozen_string_literal: true

module Admin
  class MovieEntriesController < AdminController
    def most_popular      
      @name = CGI.unescape(params[:name])
      @entries = Entry.where(id: MovieEntry.where(name: @name).select(:entry_id)).page(params[:page] || 1)
    end
  end
end
