# A user's filter hiding entries whose title or summary match it. A keyword filter matches
# entries containing all of its words (full-text, stemmed and case-insensitive); a regexp
# filter matches entries whose title or summary match the Ruby regular expression.
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
class Filter < ApplicationRecord
  belongs_to :user

  enum :kind, { keyword: "keyword", regexp: "regexp" }, validate: true

  normalizes :value, with: ->(value) { value.strip }

  validates :value, presence: true, uniqueness: { scope: [ :user_id, :kind ] }
  validate :value_is_a_valid_regexp, if: :regexp?
  validate :value_has_words, if: :keyword?

  # The words of a keyword filter, as used for full-text matching.
  def keywords
    value.to_s.scan(/[[:alnum:]]+/)
  end

  private
    def value_is_a_valid_regexp
      Regexp.new(value.to_s)
    rescue RegexpError => e
      errors.add(:value, "is not a valid regular expression: #{e.message}")
    end

    def value_has_words
      errors.add(:value, "must contain at least one word") if value.present? && keywords.empty?
    end
end
