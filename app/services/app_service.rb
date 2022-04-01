module AppService
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  module ClassMethods
    def call(...)
      new(...).tap(&:call)
    end
  end

  def success?
    errors.none?
  end

  def failure?
    !success?
  end
end
