module RssEntries
  # Deletes entries stored more than MAX_AGE ago, keeping bookmarked ones.
  # Scheduled in config/recurring.yml.
  class PurgeOldJob < ApplicationJob
    MAX_AGE = 2.weeks

    queue_as :default

    def perform
      deleted = RssEntry.where(created_at: ...MAX_AGE.ago).where.missing(:bookmarks).in_batches.delete_all
      Rails.logger.info("[#{self.class.name}] deleted #{deleted} entries older than #{MAX_AGE.inspect}")
    end
  end
end
