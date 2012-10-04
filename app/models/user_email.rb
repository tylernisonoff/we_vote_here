class UserEmail < ActiveRecord::Base
  attr_accessible :user_id, :email

  belongs_to :user

  validates :user_id, presence: true
  validates :email, presence: true, uniqueness: true

  after_create :sync_voter_emails

	def sync_voter_emails
	  	# searches through voters to see if any of them have this email,
	  	# and updates their user_id field accordingly
	  	if ValidEmail.exists?(email: self.email)
		  	valid_emails = ValidEmail.find(:all, conditions: {email: self.email})
		  	valid_emails.each do |valid_email|
		  		voter = valid_email.voter
		  		voter.user_id = self.user_id
		  		voter.save
		  	end
		end
	end
end
