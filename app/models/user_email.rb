class UserEmail < ActiveRecord::Base
  attr_accessible :user_id, :email

  belongs_to :user

  validates :user_id, presence: true
  validates :email, presence: true, uniqueness: true

end
