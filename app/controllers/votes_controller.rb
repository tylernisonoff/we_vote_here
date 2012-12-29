class VotesController < ApplicationController
  respond_to :html, :json

  def display
   	vote_id = params[:id]
    if Vote.exists?(vote_id)
      @vote = Vote.find(vote_id)
      @preferences = Preference.find(:all, conditions: {vote_id: vote_id})
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
      @vote.destroy
      unless Preference.exists?(svc: svc, active: true)
        flash[:warning] = "There are now no active preferences for your SVC. Change that by clicking the 'Vote' button!"
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

    if Vote.exists?(svc: svc, active: true)
      @active_vote = Vote.find(:first, conditions: {svc: svc, active: true})
      @active_preferences = Preference.find(:all, conditions: {svc: svc, active: true})
      @active_preferences.sort! { |a, b| a.position <=> b.position }
    end
  end

  def all
    svc = params[:svc]
    @valid_svc = ValidSvc.find_by_svc(svc)
    @votes = Vote.find(:all, conditions: {svc: svc})
    @votes.sort! { |a, b| a.created_at <=> b.created_at}
    if Vote.exists?(svc: svc, active: true)
      @active_vote = Vote.find(:first, conditions: {svc: svc, active: true})
    end
  end

  def activate
      # make sure you can only activate a vote knowing an SVC
      
      svc = params[:svc]
      vote_id = params[:id]

      if match(vote_id, svc)

        @vote_to_activate = Vote.find(vote_id)
        @election = @vote_to_activate.election
        if @election.start_time > Time.now  
          flash[:error] = "This election has not started yet."
          redirect_to results_election_path(@election)
        elsif @election.finish_time < Time.now
          flash[:error] = "This election has already ended."
          redirect_to results_election_path(@election)
        else  
          @vote_to_activate.activate_vote

          @active_vote = Vote.find(:first, conditions: {svc: svc, active: true})
          @active_preferences = Preference.find(:all, conditions: {vote_id: vote_id, active: true})
          @active_preferences.sort! { |a, b| a.position <=> b.position }
        end
      else
        flash[:error] = "You tried to activate a vote using the wrong SVC."
      end
      
      redirect_to status_vote_path(svc)

    end

  def vote
    svc = params[:svc]
    if ValidSvc.exists?(svc: svc)
      @valid_svc = ValidSvc.find_by_svc(svc)
      @election = @valid_svc.election
      @choices = @election.choices
      @results = @election.results
      choice_to_results = @election.choice_result_hash
      @choices.sort! do |a, b|
        choice_to_results[a.id] <=> choice_to_results[b.id]
      end
      if @election.start_time > Time.now  
        flash[:error] = "This election has not started yet."
        redirect_to results_election_path(@election)
      elsif @election.finish_time < Time.now
        flash[:error] = "This election has already ended."
        redirect_to results_election_path(@election)
      end 
    else
      flash[:error] = "This is an invalid SVC."
      redirect_back_or root_path
    end
  end

  def sort
    unless params["choice"].blank?
      choices = Array.new
      params["choice"].each do |str|
        choices.push(str.to_i)
      end
      @valid_svc = ValidSvc.find_by_svc(params[:svc])
      @election = @valid_svc.election
      @vote = Vote.new
      @vote.svc = @valid_svc.svc
      @vote.election_id = @election.id
      if @vote.save
        election_choices = @election.choice_id_array
        n = election_choices.size
        choices.each_with_index do |choice_id, i|
          @preference = Preference.new
          @preference.svc = @vote.svc
          @preference.vote_id = @vote.id
          @preference.choice_id = choice_id
          @preference.position = i + 1
          @preference.save
        end
        not_voted_on = election_choices - choices
        not_voted_on.each do |choice_id|
          @preference = Preference.new
          @preference.svc = @vote.svc
          @preference.vote_id = @vote.id
          @preference.choice_id = choice_id
          @preference.position = n
          @preference.save
        end
        @vote.activate_vote
      else
        flash[:error] = "We were unable to save your vote :("
      end
    else
      flash[:warning] = "You didn't submit any preferences!"
    end
    render nothing: true
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
