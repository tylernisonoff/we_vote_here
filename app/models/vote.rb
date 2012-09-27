class Vote < ActiveRecord::Base
	# require 'random'

	attr_accessible :election_id, :svc, :id, :active
	
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
			@active_vote = Vote.find(:first, conditions: {svc: svc, active: true})
			@active_vote.active = false
			@active_vote.save

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
	end

	def trash_vote
		self.trashed = true
		self.save
		self.preferences.each do |preference|
			preference.trash_preference
		end
	end

end