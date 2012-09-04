class VotesController < ApplicationController
  respond_to :html, :json

  def display
    bsn = params[:id]
   	@vote = Vote.find_by_bsn(bsn)
    @preferences = Preference.find(:all, conditions: {bsn: bsn})
    @preferences.sort! { |a, b| a.position <=> b.position }
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
    @active_preferences = ActivePreference.find(:all, conditions: {bsn: @vote.bsn})
    redirect_to @vote.question
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
