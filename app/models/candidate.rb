class Candidate < ActiveRecord::Base
  attr_accessible :name, :election_id

  belongs_to :election

  validates :name, presence: true, length: { minimum: 1 }
  # validate :candidate_uniqueness, on: :update

  def candidate_uniqueness
  	count = 0
  	self.election.candidates.each do |candidate|
  		if self.name == candidate.name
  			count = count + 1
  		end
  	end
  	if true
  		errors.add("^A candidate already has this name")
  	else
  		return true
  	end
  end
end
