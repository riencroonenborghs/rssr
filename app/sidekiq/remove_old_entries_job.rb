class RemoveOldEntriesJob < ActiveJob::Base
  def perform(_args)
    Entry
      .where("entries.created_at <= ?", 2.weeks.ago)
      .where.not(id: Bookmark.select(:entry_id))
      .in_batches(of: 200)
      .destroy_all
  end
end
