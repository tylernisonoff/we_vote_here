class Vote < ActiveRecord::Base
	attr_accessible :question_id, :svc, :bsn

	has_many :preferences, foreign_key: :bsn
	belongs_to :question

	def to_param
		bsn
	end
	
	def assign_svc(svc = false)
	  unless svc
	  	@question = self.question
	  	@valid_svc = @question.valid_svcs.build
      	@valid_svc.svc = SecureRandom.urlsafe_base64
      	@valid_svc.save
      else
      	if ValidSvc.exists?(svc: svc)
      		@valid_svc = ValidSvc.find_by_svc(svc)
      	else
      		return false
      		# We passed through an SVC that doesn't exist
      		# This would mean there is an error where this is called
      	end
      end
      self.svc = @valid_svc.svc
    end

   	def assign_bsn
   		self.bsn = SecureRandom.urlsafe_base64
    end

	def activate_vote
		if ActiveVote.exists?(svc: svc)
			@active_vote = ActiveVote.find_by_svc(svc)
      	else
      		@active_vote = ActiveVote.new
      		@active_vote.svc = svc
      		@active_vote.question_id = question_id
      	end
      	@active_vote.bsn = bsn
      	if @active_vote.save	
			@current_preferences = ActivePreference.find(:all, conditions: {svc: svc})
	    	@current_preferences.each do |current_preference|
	      		current_preference.delete
	      	end

	      	@new_preferences = Preference.find(:all, conditions: {bsn: bsn})
	    	@new_preferences.each do |new_preference|
	    		new_preference.make_active
	    	end
	    else
	    	flash[:error] = "There was an error activating this vote :("
		end
	end

	# Goal: try to make this function obsolete
	def check_last_bsn(bsn)
		svc = self.svc
		@last_vote = Vote.find(:last, conditions: {svc: svc})
		if bsn == @last_vote.bsn
			return true
		else
			return false
		end
	end

	def forget_vote(bsn)
		@vote = Vote.find_by_bsn(bsn)
		@vote.delete
		if ActiveVote.exists?(bsn: bsn)
			@active_vote = ActiveVote.find_by_bsn(bsn)
			@active_vote.delete
		end
	end

end