require "rails_helper"

RSpec.describe CreateManualSubscription, type: :service do
  shared_examples "the service fails" do
    it "copies the errors" do
      expect(subject.errors.full_messages.to_sentence).to_not eq ""
    end
    it "is a failure" do
      expect(subject.failure?).to be true
    end
  end

  let(:user) { create :user }
  let(:name) { "Name" }
  let(:tag_list) { "foo,bar,baz" }
  let(:url) { Faker::Internet.url }
  let(:description) { "description" }

  subject { described_class.call user: user, name: name, tag_list: tag_list, url: url, description: description }

  describe ".call" do
    context "when feed is new" do
      it "creates the feed" do
        expect do
          subject
        end.to change(Feed, :count).by(1)
      end

      it "creates the subscription" do
        expect do
          subject
        end.to change(Subscription, :count).by(1)
      end

      it "is a success" do
        expect(subject.success?).to be true
      end
    end

    context "when feed exists" do
      let!(:feed) { create :feed, url: url }

      it "does not creates the feed" do
        expect do
          subject
        end.to_not change(Feed, :count)
      end

      it "creates the subscription" do
        expect do
          subject
        end.to change(Subscription, :count).by(1)
      end

      it "is a success" do
        expect(subject.success?).to be true
      end
    end
  end
end
