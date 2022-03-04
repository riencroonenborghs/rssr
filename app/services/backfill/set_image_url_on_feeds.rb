module Backfill
  class SetImageUrlOnFeeds < AppService
    def call
      Feed.where(image_url: nil).each do |feed|
        pp "feed #{feed.name} (#{feed.url})"
        feed.guess_image_url
        if feed.image_url_changed?
          pp "-- found url, saving"
          feed.save
        end
      rescue StandardError => e
        pp "-- something's up"
        pp e.message
      end
    end
  end
end
