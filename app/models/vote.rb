class Vote < ActiveRecord::Base
	# require 'random'

	attr_accessible :election_id, :svc, :id, :active, :tie_breaking
	
	has_many :preferences, dependent: :destroy

	belongs_to :election

	def assign_vote_svc(svc)
	    if ValidSvc.exists?(svc: svc)
	      @valid_svc = ValidSvc.find_by_svc(svc)
	      self.svc = @valid_svc.svc
	    else
	      return false    
	    end
    end

	def activate_vote
		if Vote.exists?(svc: svc, active: true)
			@active_votes = Vote.find(:all, conditions: {svc: svc, active: true})
			@active_votes.each do |vote|
				vote.active = false
				vote.save
			end

			@current_active_preferences = Preference.find(:all, conditions: {svc: svc, active: true})
      		@current_active_preferences.each do |current_preference|
      			current_preference.deactivate_preference
      		end
      	end
      	self.active = true
      	if self.save
	      	@new_active_preferences = Preference.find(:all, conditions: {vote_id: self.id})
	    	@new_active_preferences.each do |new_preference|
	    		new_preference.activate_preference
	    	end
		end
		self.election.ranked_pairs
	end

end