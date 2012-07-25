class Vote < ActiveRecord::Base
	attr_accessible :question_id, :svc, :bsn

	has_many :active_preferences, foreign_key: :svc
	has_many :preferences, foreign_key: :bsn
	belongs_to :question

	accepts_nested_attributes_for :active_preferences, allow_destroy: true, reject_if: lambda { |c| c.values.all?(&:blank?) }

	def to_param
		svc
	end
	
	def assign_svc(svc = false)
	  unless svc
	  	@question = self.question
	  	@valid_svc = @question.valid_svcs.build
      	@valid_svc.svc = SecureRandom.urlsafe_base64
      	@valid_svc.save
      else
      	@valid_svc = ValidSvc.find_by_svc(svc)
      end
      self.svc = @valid_svc.svc
    end

   	def assign_bsn
   		self.bsn = SecureRandom.urlsafe_base64
    end

	def activate_vote
		@current_preferences = ActivePreference.find(:all, conditions: {svc: svc})
    	@current_preferences.each do |current_preference|
      		current_preference.delete
      	end

      	@new_preferences = Preference.find(:all, conditions: {bsn: bsn})
    	@new_preferences.each do |new_preference|
    		new_preference.make_active
    	end
	end

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
	end

end