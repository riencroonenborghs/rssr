# Base for service objects: Service.call(...) is Service.new(...).call.
class ApplicationService
  def self.call(...)
    new(...).call
  end
end
