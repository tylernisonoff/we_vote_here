class Voter < ActiveRecord::Base
  attr_accessible :election_id, :valid_emails_attributes, :user_id

  has_many :valid_emails, dependent: :destroy

  belongs_to :user
  belongs_to :group

  def trash_voter
  	self.trashed = true
  	if self.save
  		self.valid_emails.each do |valid_email|
  			valid_email.trash_valid_email
  		end
  	end
  end

end