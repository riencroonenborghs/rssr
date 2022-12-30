shared_examples "the service fails with error" do |error|
  it "fails" do
    subject.perform
    expect(subject.failure?).to be true
  end

  it "has the error" do
    subject.perform
    expect(subject.errors.full_messages).to include error
  end
end

shared_examples "the service fails" do
  it "fails" do
    subject.perform
    expect(subject.failure?).to be true
  end

  it "has the error" do
    subject.perform
    expect(subject.errors.full_messages).to include error_message
  end
end
