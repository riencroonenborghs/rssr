# frozen_string_literal: true

RSpec.describe UpdateSubscription, type: :service do
  subject { described_class.perform(user: user, id: id, params: params) }

  let(:user) { create(:user) }
  let(:id) { subscription.id }
  let(:params) { { hide_from_main_page: hide_from_main_page, tag_list: tag_list, description: description} }
  let(:hide_from_main_page) { true }
  let(:tag_list) { %w[a bc d] }
  let(:description) { "description" }
  let(:subscription) { create(:subscription, user: user) }

  context "when subscription was not found" do
    let(:id) { "some id" }

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "No subscription found"
    end
  end

  context "when updating the subscription fails" do
    before do
      allow(user.subscriptions).to receive(:find_by).and_return(subscription)
      allow(subscription).to receive(:save).and_return(false)
      errors = ActiveModel::Errors.new(Subscription)
      errors.add(:base, "some error")
      allow(subscription).to receive(:errors).and_return(errors)
    end

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "some error"
    end
  end

  context "when updating the feed fails" do
    before do
      allow(user.subscriptions).to receive(:find_by).and_return(subscription)
      allow(subscription.feed).to receive(:save).and_return(false)
      errors = ActiveModel::Errors.new(Subscription)
      errors.add(:base, "some other error")
      allow(subscription.feed).to receive(:errors).and_return(errors)
    end

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "some other error"
    end
  end

  it "succeeds" do
    expect(subject).to be_success
  end

  it "updates the subscription and the feed" do
    expect { subject }.to change { subscription.reload.hide_from_main_page }.to(hide_from_main_page)
    .and change { subscription.tag_list }.to(tag_list)
    .and change { subscription.feed.description }.to(description)
  end
end
