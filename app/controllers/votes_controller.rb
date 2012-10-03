class VotesController < ApplicationController
  respond_to :html, :json

  def display
   	vote_id = params[:id]
    if Vote.exists?(vote_id)
      @vote = Vote.find(vote_id)
      @preferences = Preference.find(:all, conditions: {vote_id: vote_id, trashed: false})
      @preferences.sort! { |a, b| a.position <=> b.position }
    else
      flash[:error] = "Sorry, that is an invalid BSN."
      redirect_back_or root_path  
    end
  end
  
  def destroy
    svc = params[:svc]
    vote_id = params[:id]
    if match(vote_id, svc)
      @vote = Vote.find(vote_id)    
      @vote.trash_vote
      unless Preference.exists?(svc: svc, active: true, trashed: false)
        flash[:warning] = "There are now no active preferences for your SVC. Change that!"
      end
      redirect_to status_vote_path(svc: svc)
    else
      flash[:error] = "Sorry, the SVC does not match the BSN"
      redirect_back_or root_path
    end
  end

  def status
    svc = params[:svc]
    @valid_svc = ValidSvc.find_by_svc(svc)
    @votes = Vote.find(:all, conditions: {svc: svc, trashed: false})
    @votes.sort! { |a, b| a.created_at <=> b.created_at}

    if Vote.exists?(svc: svc, active: true)
      @active_vote = Vote.find(:first, conditions: {svc: svc, active: true, trashed: false})
      @active_preferences = Preference.find(:all, conditions: {svc: svc, active: true, trashed: false})
      @active_preferences.sort! { |a, b| a.position <=> b.position }
    end
  end

  def activate
      # make sure you can only activate a vote knowing an SVC
      
      svc = params[:svc]
      vote_id = params[:id]

      if match(vote_id, svc)
        @vote_to_activate = Vote.find(vote_id)
        @vote_to_activate.activate_vote

        @active_vote = Vote.find(:first, conditions: {svc: svc, active: true, trashed: false})
        @active_preferences = Preference.find(:all, conditions: {vote_id: vote_id, active: true})
        @active_preferences.sort! { |a, b| a.position <=> b.position }
      else
        flash[:error] = "You tried to activate a vote using the wrong SVC."
      end
      
      redirect_to status_vote_path(svc)

    end

  def vote
    svc = params[:svc]
    puts "\n\n\n\n\n\n#{params}\n\n\n\n"
    if ValidSvc.exists?(svc: svc)
      @valid_svc = ValidSvc.find_by_svc(svc)
      @election = @valid_svc.election
      @vote = Vote.new
      @vote.election = @election
      @vote.assign_vote_svc(svc)
      unless @vote.save
        flash[:error] = "We were unable to save your vote"
        redirect_to @election
      end
    else
      flash[:error] = "This is an invalid SVC."
      redirect_back_or root_path
    end
  end

	private

    # I don't know where I use this, but I should use it.
		def correct_user
	  		@user = User.find(params[:id])
	  		redirect_to root_path unless @vote.user_id == current_user.id 
        # redirect to group page
		end

    def match(vote_id, svc)
      # if they match, return true
      # if not, return false
      if Vote.exists?(id: vote_id)
        @vote = Vote.find(vote_id)
        if svc == @vote.svc
          return true
        else
          flash[:error] = "You tried to destroy a vote using the wrong SVC."
          return false
        end
      else
        flash[:error] = "This BSN does not exist"
        return false
      end
    end

end
