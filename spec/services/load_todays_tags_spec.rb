require "rails_helper"

RSpec.describe LoadTodaysTags, type: :model do
  subject { described_class.call }

  let!(:tag1) { Faker::Lorem.word }
  let!(:tag2) { Faker::Lorem.word }
  let!(:tag3) { Faker::Lorem.word }
  let!(:tag4) { Faker::Lorem.word }
  let!(:tag5) { Faker::Lorem.word }
  let!(:tag6) { Faker::Lorem.word }

  let(:taggable_tag1) { ActsAsTaggableOn::Tag.find_by name: tag1 }
  let(:taggable_tag2) { ActsAsTaggableOn::Tag.find_by name: tag2 }
  let(:taggable_tag3) { ActsAsTaggableOn::Tag.find_by name: tag3 }
  let(:taggable_tag4) { ActsAsTaggableOn::Tag.find_by name: tag4 }
  let(:taggable_tag5) { ActsAsTaggableOn::Tag.find_by name: tag5 }
  let(:taggable_tag6) { ActsAsTaggableOn::Tag.find_by name: tag6 }

  let!(:user) { create :user }
  let!(:feed1) { create :feed, user: user, tag_list: [tag1, tag2, tag3].join(",") }
  let!(:feed2) { create :feed, user: user, tag_list: [tag2, tag4].join(",") }
  let!(:feed3) { create :feed, user: user, tag_list: [tag1, tag5, tag6].join(",") }

  let(:now) { 48.hours.ago }

  before do
    100.times do |i|
      create :entry, feed: feed1, published_at: now + i.hours
    end

    30.times do |i|
      create :entry, feed: feed2, published_at: now + i.hours
    end

    12.times do |i|
      create :entry, feed: feed3, published_at: now + i.hours
    end
  end

  describe ".call" do
    it "returns tags in last 24 hours" do
      expect(subject.tags).to include(
        taggable_tag1, taggable_tag2, taggable_tag3, taggable_tag4
      )
    end

    it "omits tags older than last 24 hours" do
      expect(subject.tags).to_not include(
        taggable_tag5, taggable_tag6
      )
    end

    it "returns counts per tag" do
      expect(subject.tag_count_by_tag).to include(taggable_tag1 => 75)
      expect(subject.tag_count_by_tag).to include(taggable_tag2 => 80)
      expect(subject.tag_count_by_tag).to include(taggable_tag3 => 75)
      expect(subject.tag_count_by_tag).to include(taggable_tag4 => 5)
    end

    it "returns feeds by tag" do
      expect(subject.feeds_by_tag[taggable_tag1]).to include(feed1)
      expect(subject.feeds_by_tag[taggable_tag2]).to include(feed1, feed2)
      expect(subject.feeds_by_tag[taggable_tag3]).to include(feed1)
      expect(subject.feeds_by_tag[taggable_tag4]).to include(feed2)
    end
  end
end
