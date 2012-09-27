class ValidEmail < ActiveRecord::Base
  attr_accessible :email, :voter_id, :group_id, :trashed

  belongs_to :group
  belongs_to :voter

  def trash_valid_email
  	self.trashed = true
  	self.save
  end
  
end
