# Stubs the Claude Messages API with a streamed response of the given text, returning the stub so
# specs can assert on the request.
module AnthropicStubs
  def stub_claude_summary(text, stop_reason: "end_turn")
    events = [
      [ "message_start", { type: "message_start", message: { id: "msg_1", type: "message", role: "assistant", model: "claude-opus-5-5",
                                                            content: [], stop_reason: nil, stop_sequence: nil,
                                                            usage: { input_tokens: 10, output_tokens: 1 } } } ],
      [ "content_block_start", { type: "content_block_start", index: 0, content_block: { type: "text", text: "" } } ],
      [ "content_block_delta", { type: "content_block_delta", index: 0, delta: { type: "text_delta", text: text } } ],
      [ "content_block_stop", { type: "content_block_stop", index: 0 } ],
      [ "message_delta", { type: "message_delta", delta: { stop_reason: stop_reason, stop_sequence: nil }, usage: { output_tokens: 5 } } ],
      [ "message_stop", { type: "message_stop" } ]
    ]
    body = events.map { |name, data| "event: #{name}\ndata: #{data.to_json}\n\n" }.join

    stub_request(:post, %r{\Ahttps://api\.anthropic\.com/v1/messages})
      .to_return(status: 200, body: body, headers: { "Content-Type" => "text/event-stream" })
  end
end

RSpec.configure { |config| config.include AnthropicStubs }
