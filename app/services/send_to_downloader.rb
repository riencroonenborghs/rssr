# frozen_string_literal: true

class SendToDownloader
  include Base

  def initialize(url:)
    @url = url
  end

  def perform
    send_request
    return if failure?

    parse_response
  end

  private

  def send_request
    @response = HTTParty.post(
      ENV.fetch("DOWNLOADER_URL"),
      body: {
        download: {
          url: @url
        }
      }
    )
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  def parse_response
    return if @response.success?

    errors.add(:base, "Could not send to downloader: #{@response.code} #{@response.body}")
  end
end
