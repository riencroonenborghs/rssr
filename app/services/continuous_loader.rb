class ContinuousLoader < AppService
  def call
    Feed.all.map(&:visit!)
    queue
  end

  def queue
    self.class.call
  end

  handle_asynchronously :queue, run_at: Proc.new { 15.minutes.from_now }
end