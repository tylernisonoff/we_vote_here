class ActiveVotesController < ApplicationController
	
	def activate
	    # make sure you can only activate a vote knowing an SVC
	    
	    svc = params[:id]
	    bsn = params[:bsn]

	    @vote_to_activate = Vote.find_by_bsn(bsn)
	    @vote_to_activate.activate_vote

	    @active_vote = ActiveVote.find_by_svc(svc)
	    @active_preferences = ActivePreference.find(:all, conditions: {bsn: bsn})
  		@active_preferences.sort! { |a, b| a.position <=> b.position }
  	end

  	def status
	    svc = params[:id]
	    @valid_svc = ValidSvc.find_by_svc(svc)
	    @votes = Vote.find(:all, conditions: {svc: svc})
	    
	    if ActiveVote.exists?(svc: svc)
	    	@active_vote = ActiveVote.find_by_svc(svc)
	    	@active_preferences = ActivePreference.find(:all, conditions: {svc: svc})
  			@active_preferences.sort! { |a, b| a.position <=> b.position }
  		end
  	end

end
