# Stubs the Claude Messages API with a response of the given text, returning the stub so specs
# can assert on the request.
module AnthropicStubs
  def stub_claude_summary(text, stop_reason: "end_turn")
    body = { id: "msg_1", type: "message", role: "assistant", model: "claude-opus-5-5",
             content: [ { type: "text", text: text } ], stop_reason: stop_reason, stop_sequence: nil,
             usage: { input_tokens: 10, output_tokens: 5 } }

    stub_request(:post, %r{\Ahttps://api\.anthropic\.com/v1/messages})
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end
end

RSpec.configure { |config| config.include AnthropicStubs }
