class RemoveOldEntriesJob
  include Sidekiq::Job

  def perform
    Entry
      .where("entries.created_at <= ?", 2.weeks.ago)
      .where.not(id: ReadLaterEntry.select(:id))
      .in_batches(of: 200)
      .destroy_all
  end
end
