class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable

  has_many :user_feeds, foreign_key: :user_id, dependent: :destroy
  has_many :feeds, through: :user_feeds
  
  has_many :filter_engine_rules, dependent: :destroy, class_name: "FilterEngine::Rule"
end
