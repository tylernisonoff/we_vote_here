class VotesController < ApplicationController
  respond_to :html, :json

  def activate
    bsn = params[:id]
    @vote_to_activate = Vote.find_by_bsn(bsn)
    @vote_to_activate.activate_vote

    @activated_vote = Vote.find_by_bsn(bsn)
    svc = @activated_vote.svc
    @active_preferences = ActivePreference.find(:all, conditions: {svc: svc})
  end

  def show
    svc = params[:id]
    if @vote
      @vote.assign_bsn
      unless @vote.save
        flash[:error] = "We were unable to save your vote"
        redirect_to @question
      end
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

  def display
    bsn = params[:id]
   	@vote = Vote.find_by_bsn(bsn)
    svc = @vote.svc
    if bsn == active_bsn(svc)
      @preferences = ActivePreference.find(:all, conditions: {svc: svc})
    else
      @preferences = Preference.find(:all, conditions: {bsn: bsn})
    end
  end

  def status
    svc = params[:id]
    @votes = Vote.find(:all, conditions: {svc: svc})
    @active_bsn = active_bsn(svc)
    @active_vote = Vote.find_by_bsn(@active_bsn)
    @active_preferences = ActivePreference.find(:all, conditions: {svc: svc})
  end

  def clear
    bsn = params[:id]
    if Vote.exists?(bsn: bsn)
      @vote = Vote.find_by_bsn(bsn)
      if @vote.check_last_bsn(bsn)
        @vote.forget_vote(bsn)
      else
        flash[:error] = "Sorry, you can only delete your last vote"
      end
    else
      flash[:error] = "This BSN does not exist"
      redirect_back_or root_path
    end
  end    

	private

		def correct_user
	  		@user = User.find(params[:id])
	  		redirect_to root_path unless @vote.user_id == current_user.id # redirect to election page
		end

		def active_bsn(svc)
			if ActivePreference.exists?(svc: svc)
        @preference = ActivePreference.find(:first, conditions: {svc: svc})
        bsn = @preference.bsn
        return bsn
			else
        return false
    	end
  	end
end
