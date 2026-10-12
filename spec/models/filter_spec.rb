require "rails_helper"

# == Schema Information
#
# Table name: filters
# Database name: primary
#
#  id         :integer          not null, primary key
#  kind       :string           not null
#  value      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_filters_on_user_id                     (user_id)
#  index_filters_on_user_id_and_kind_and_value  (user_id,kind,value) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
RSpec.describe Filter do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  it "strips the value" do
    expect(user.filters.create!(kind: :keyword, value: "  apple ").value).to eq("apple")
  end

  it "requires a known kind" do
    expect(user.filters.new(kind: "glob", value: "apple")).not_to be_valid
  end

  it "requires a value" do
    expect(user.filters.new(kind: :keyword, value: " ")).not_to be_valid
  end

  it "does not allow the same filter twice for a user" do
    user.filters.create!(kind: :keyword, value: "apple")

    expect(user.filters.new(kind: :keyword, value: "apple")).not_to be_valid
    expect(user.filters.new(kind: :regexp, value: "apple")).to be_valid
  end

  describe "keyword filters" do
    it "splits the value into words" do
      expect(described_class.new(kind: :keyword, value: %(apple, "watch" ultra-2)).keywords)
        .to eq(%w[apple watch ultra 2])
    end

    it "requires at least one word" do
      filter = user.filters.new(kind: :keyword, value: "!!!")

      expect(filter).not_to be_valid
      expect(filter.errors[:value]).to include("must contain at least one word")
    end
  end

  describe "regexp filters" do
    it "requires a valid regular expression" do
      filter = user.filters.new(kind: :regexp, value: "(unclosed")

      expect(filter).not_to be_valid
      expect(filter.errors[:value].first).to start_with("is not a valid regular expression")
    end
  end
end
