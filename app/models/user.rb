# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :nickname, :email, :handle, :password, :password_confirmation
  has_secure_password

  has_many :elections, dependent: :destroy
  has_many :votes
  # has_many :microposts, dependent: :destroy
  # has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  # has_many :followed_users, through: :relationships, source: :followed
  # has_many :reverse_relationships, foreign_key: "followed_id",
                                   # class_name:  "Relationship",
                                   # dependent:   :destroy
  # has_many :followers, through: :reverse_relationships, source: :follower

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  # validates :name, presence: true, length: { maximum: 50 }
  validates :nickname, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_HANDLE_REGEX = /^[^@]*$/

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  					uniqueness: { case_sensitive: false }
  validates :handle, presence: true, format: { with: VALID_HANDLE_REGEX, message: "cannot contain the '@' character" },
            uniqueness: { case_sensitive: false }, length: { minimum: 2 }          
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  # def feed
  #   Micropost.from_users_followed_by(self)
  # end

  # def following?(other_user)
  #   relationships.find_by_followed_id(other_user.id)
  # end

  # def follow!(other_user)
  #   relationships.create!(followed_id: other_user.id)
  # end

  # def unfollow!(other_user)
  #   relationships.find_by_followed_id(other_user.id).destroy
  # end

  private
  	
  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
end