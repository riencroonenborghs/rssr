# frozen_string_literal: true

module Notegpt
  class Chat
    include Service
    include HTTParty

    attr_reader :response, :data

    MODEL = "gemini-3.1-flash-lite-preview"

    debug_output $stderr
    base_uri "https://notegpt.io/api/v2"
    headers({
      "Content-Type" => "application/json"
    })

    def initialize(prompt:)
      @prompt = prompt
    end

    def perform
      build_message
      send_request
      parse_response
    end

    private

    def build_message
      @message = {
        conversation_id: SecureRandom.uuid,
        image_urls: [],
        language: :auto,
        length: :moderate,
        message: @prompt,
        model: MODEL,
        tone: "default"
      }
    end

    def send_request
      @response = self.class.post("/chat/stream", { body: @message.to_json })
    end

    def parse_response
      re = /data: \{\"text\": \"(.*)\"\}/
      pp @response.body
      @data = @response.body.split("\n").map do |line|
        match = line.match(re)
        match ? match[1] : nil
      end.compact
    end
  end
end
