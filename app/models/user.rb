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
  attr_accessible :nickname, :email, :user_emails, :old_password, :password, :password_confirmation, :pretty_name, :trashed
  has_secure_password
  require 'set'

  has_many :user_emails, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :voters

  accepts_nested_attributes_for :user_emails, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_save :check_user_emails

  after_create :deliver_signup_notification
  after_create :add_to_user_emails

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

  def check_user_emails
    if UserEmail.exists?(email: self.email)
      errors.add(:user_emails, "^Sorry, another account is already using that email!")
      return false
    else
      return true
    end
  end

  def followed_groups
    user_emails = UserEmail.find(:all, conditions: {user_id: self.id})
    valid_emails = Array.new
    user_emails.each do |user_email|
      if ValidEmail.exists?(email: user_email.email)
        valid_emails = valid_emails + ValidEmail.find(:all, conditions: {email: user_email.email})
      end
    end
    total_groups = Set.new
    if valid_emails.any?
      valid_emails.each do |valid_email|
        unless valid_email.voter.trashed
          total_groups.add(Group.find(valid_email.group_id))
        end
      end
    end
    followed_groups_set = total_groups - self.groups.to_set
    followed_groups = followed_groups_set.to_a
    followed_groups.sort! { |a, b| a.created_at <=> b.created_at }
    return followed_groups
  end

  def add_to_user_emails
    @user_email = UserEmail.new
    @user_email.email = self.email
    @user_email.user_id = self.id
    @user_email.save
  end

  def pretty_name
    if !nickname.blank? && !nickname.nil?
      return nickname
    else
      return email
    end
  end

  def trash_user
    self.trashed = true
    self.save
  end

  private

  	def create_remember_token
  		self.remember_token = SecureRandom.urlsafe_base64
  	end
end