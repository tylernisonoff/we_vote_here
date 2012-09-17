class Vote < ActiveRecord::Base
	# require 'random'

	attr_accessible :question_id, :svc, :id
	
	has_one :active_vote, dependent: :destroy
	has_many :preferences, dependent: :destroy

	belongs_to :question

	def assign_vote_svc(svc)
	    if ValidSvc.exists?(svc: svc)
	      @valid_svc = ValidSvc.find_by_svc(svc)
	      self.svc = @valid_svc.svc
	    else
	      return false    
	    end
    end

	def activate_vote
		if ActiveVote.exists?(svc: svc)
			@active_vote = ActiveVote.find_by_svc(svc)
      	else
      		@active_vote = ActiveVote.new
      		@active_vote.svc = svc
      		@active_vote.question_id = question_id
      	end
      	@active_vote.vote_id = self.id
      	if @active_vote.save	
			@current_preferences = ActivePreference.find(:all, conditions: {svc: svc})
	    	@current_preferences.each do |current_preference|
	      		current_preference.delete
	      	end

	      	@new_preferences = Preference.find(:all, conditions: {vote_id: self.id})
	    	@new_preferences.each do |new_preference|
	    		new_preference.make_active
	    	end
	    else
	    	flash[:error] = "There was an error activating this vote :("
		end
	end

	def destroy_vote
		self.destroy
		if ActiveVote.exists?(vote_id: self.id)
			@active_vote = ActiveVote.find_by_vote_id(self.id)
			@active_vote.delete
		end
	end

end