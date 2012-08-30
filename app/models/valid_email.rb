class ValidEmail < ActiveRecord::Base
  attr_accessible :email, :voter_id, :election_id

  belongs_to :election
  belongs_to :voter

  
end
