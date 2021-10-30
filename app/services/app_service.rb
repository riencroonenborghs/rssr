class AppService
  include ActiveModel::Validations

  def self.call(*args, &block)
    new(*args, &block).tap(&:call)
  end

  def success?
    errors.full_messages.none?
  end

  def failure?
    errors.full_messages.any?
  end
end
