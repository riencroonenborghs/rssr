# frozen_string_literal: true

# Log to both log/<environment>.log and STDOUT. The test environment only logs to its file
# to keep spec output readable.
#
# Extra outputs are plain loggers sharing the main logger's formatter, so they still print tags.
# They must not be TaggedLogging loggers: BroadcastLogger forwards `tagged { ... }` to every logger
# that responds to it, which would run the block (e.g. enqueueing or performing a job) once per logger.
Rails.application.config.after_initialize do
  logger = Rails.logger
  log_file = Rails.root.join("log/#{Rails.env}.log").to_s
  outputs = [ log_file ]
  outputs << STDOUT unless Rails.env.test?

  outputs.each do |output|
    next if ActiveSupport::Logger.logger_outputs_to?(logger, output)

    broadcast = ActiveSupport::Logger.new(output)
    broadcast.formatter = logger.formatter
    broadcast.level = logger.level
    logger.broadcast_to(broadcast)
  end
end
