# frozen_string_literal: true

class FindMatchesJob < ApplicationJob
  queue_as :bootlegger

  def perform
    Entry.where.not(id: TvEntry.pluck(:entry_id).concat(MovieEntry.pluck(:entry_id))).find_each(batch_size: 100) do |entry|
      matcher = FindMatch.perform(title: entry.title)
      if matcher.tv
        TvEntry.create!(matcher.tv.update(entry: entry))
      elsif matcher.movie
        MovieEntry.create!(matcher.movie.update(entry: entry))
      end
    end
  end
end
