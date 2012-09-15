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
  attr_accessible :nickname, :email, :handle, :password, :password_confirmation, :pretty_name, :handle_or_email
  has_secure_password

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
  before_save { |user| user.handle = handle.downcase }
  before_save :create_remember_token

  after_create :deliver_signup_notification

  validates :nickname, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_HANDLE_REGEX = /^[^(@|\s)]*$/

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  					uniqueness: { case_sensitive: false }
  validates :handle, presence: true, format: { with: VALID_HANDLE_REGEX, message: "cannot contain spaces or the '@' character" },
            uniqueness: { case_sensitive: false }, length: { within: 2..20 }          
  validates :password, length: { within: 6..50 }, on: :create
  validates :password_confirmation, presence: true, on: :update, :unless => lambda{ |user| user.password.blank? }

  def deliver_signup_notification
    UserMailer.welcome_email(self)
  end

  def pretty_name
    if !nickname.blank? && !nickname.nil?
      return nickname
    else
      return handle
    end
  end

  # I believe this function doesn't do anything but is necessary
  def handle_or_email
    # Handle chosen somewhat arbitrarily, the main plus is privacy
    self.handle
  end

  # I believe this function doesn't do anything but is necessary
  def handle_or_email=(login)
    if login.include? "@"
      self.email
    else
      self.handle
    end
  end

  private

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
end