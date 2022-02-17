class RemoveOldEntriesJob < ApplicationJob
  queue_as :default

  def perform
    Entry
      .where("entries.created_at <= ?",  2.weeks.ago)
      .where.not(id: ReadLaterEntry.unread.select(:id))
      .in_batches(of: 200)
      .destroy_all
  end
end