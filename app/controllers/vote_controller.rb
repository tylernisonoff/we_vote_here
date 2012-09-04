class VoteController < ApplicationController

	def show
	    svc = params[:id]
	    if @vote
	      # Just chill, show as usual.
	    elsif ValidSvc.exists?(svc: svc)
	      @valid_svc = ValidSvc.find_by_svc(svc)
	      @question = @valid_svc.question
	      @vote = @question.votes.build
	      @vote.assign_svc(svc)
	      @vote.assign_bsn
	      unless @vote.save
	        flash[:error] = "We were unable to save your vote"
	        redirect_to @question
	      end
	    else
	      redirect_back_or root_path
	      flash[:error] = "This is an invalid SVC."
	    end
	end
end
