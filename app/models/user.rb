class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :nickname, :unconfirmed_email
  require 'set'

  has_one :voter
  has_many :groups, dependent: :destroy
  has_many :elections, dependent: :destroy

  
  after_create :sync_voter

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :nickname, length: { maximum: 50 }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false }
  validates :password, length: { within: 6..50 }, on: :create
  validates :password_confirmation, presence: true, on: :update, :unless => lambda{ |user| user.password.blank? }

  def followed_groups
    total_groups = self.voter.groups.to_set
    followed_groups_set = total_groups - self.groups.to_set
    ret = followed_groups_set.to_a
    ret.sort! { |a, b| a.created_at <=> b.created_at }
    return ret
  end

  def followed_elections
    followed_groups_set = self.followed_groups.to_set
    ret = Set.new
    followed_groups_set.each do |group|
      if group.elections.any?
        group.elections.each do |e|
          ret.add(e)
        end
      end
    end
    users_elections_set = self.elections.to_set
    ret = ret - users_elections_set
    ret = ret.to_a
    ret.sort! { |a, b| a.created_at <=> b.created_at }
    return ret
  end

  def sync_voter
    if ValidEmail.exists?(email: self.email)
      valid_email = ValidEmail.find_by_email(self.email)
      voter = valid_email.voter
      voter.user_id = self.id
      voter.save
    else
      voter = Voter.new
      voter.user_id = self.id
      if voter.save
        valid_email = ValidEmail.new
        valid_email.email = self.email
        valid_email.voter_id = self.voter.id
        valid_email.save
      end
    end
  end


  def pretty_name
    if !nickname.blank? && !nickname.nil?
      return nickname
    else
      return email
    end
  end



end
