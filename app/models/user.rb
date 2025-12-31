# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  email               :string           default(""), not null
#  encrypted_password  :string           default(""), not null
#  name                :text
#  remember_created_at :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :subscriptions, foreign_key: :user_id, dependent: :destroy
  has_many :feeds, through: :subscriptions
  has_many :viewed_entries
  has_many :bookmarks, dependent: :destroy
  has_many :filters, dependent: :destroy
end
