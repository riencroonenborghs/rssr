namespace :continuous_loader do
  desc "Start the ContinuousLoader"
  task start: :environment do
    ContinuousLoader.call
  end

  desc "Stop the ContinuousLoader"
  task stop: :environment do
    yaml = Delayed::PerformableMethod.new(ContinuousLoader.new, :queue_without_delay, []).to_yaml
    Delayed::Job.where(handler: yaml).map(&:destroy)
  end
end
