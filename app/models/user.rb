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
  attr_accessible :nickname, :email, :old_password, :password, :password_confirmation, :pretty_name
  has_secure_password

  has_many :user_emails, dependent: :destroy
  has_many :elections, dependent: :destroy
  has_many :preferences, dependent: :destroy
  # has_many :microposts, dependent: :destroy
  # has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  # has_many :followed_users, through: :relationships, source: :followed
  # has_many :reverse_relationships, foreign_key: "followed_id",
                                   # class_name:  "Relationship",
                                   # dependent:   :destroy
  # has_many :followers, through: :reverse_relationships, source: :follower

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  after_create :deliver_signup_notification

  validates :nickname, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_HANDLE_REGEX = /^[^(@|\s)]*$/

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  					uniqueness: { case_sensitive: false }
  validates :password, length: { within: 6..50 }, on: :create
  validates :password_confirmation, presence: true, on: :update, :unless => lambda{ |user| user.password.blank? }

  def deliver_signup_notification
    # Tell the UserMailer to send a welcome Email after save
    UserMailer.welcome_email(self).deliver
  end

  def pretty_name
    if !nickname.blank? && !nickname.nil?
      return nickname
    else
      return email
    end
  end

  private

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
end