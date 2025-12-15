# frozen_string_literal: true

module Service
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  module ClassMethods
    def perform(...)
      new(...).tap(&:perform)
    end
  end

  def success?
    errors.none?
  end

  def failure?
    errors.any?
  end

  private

  def add_error(message, field: :base)
    log_error(message)
    errors.add(field, message)
  end

  def copy_errors(new_errors)
    log_error(new_errors.full_messages.to_sentence)
    errors.merge!(new_errors)
  end

  def log_error(message)
    log(:error, message)
  end
  
  def log_info(message)
    log(:info, message)
  end

  def log(type, message)
    Rails.logger.send(type, formatted_message(message))
  end

  def formatted_message(message)
    "[#{self.class}] #{message}"
  end
end
