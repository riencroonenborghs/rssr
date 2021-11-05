class ContinuousLoader < AppService
  def call
    Subscription.all.map(&:feed).map(&:visit!)
    queue
  end

  def queue
    self.class.call
  end

  handle_asynchronously :queue, run_at: proc { 15.minutes.from_now }
end
