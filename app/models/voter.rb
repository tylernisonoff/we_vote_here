class Voter < ActiveRecord::Base
  attr_accessible :election_id, :valid_emails_attributes, :user_id

  has_many :valid_emails, dependent: :destroy

  belongs_to :user
 
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships, source: :group

  def merge_voters
  end

end