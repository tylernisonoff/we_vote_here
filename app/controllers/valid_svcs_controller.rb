class ValidSvcsController < ApplicationController


  def make
  # PUBLIC ELECTIONS
    @election = Election.find(params[:election_id])

    # for public groups
    unless @election.privacy
      if @election.start_time > Time.now  
        flash[:error] = "This election has not started yet."
        redirect_to results_election_path(@election)
      elsif @election.finish_time < Time.now
        flash[:error] = "This election has already ended."
        redirect_to results_election_path(@election)
      else
        @valid_svc = ValidSvc.new
        @valid_svc.election = @election
        @valid_svc.assign_valid_svc
        @valid_svc.save
        redirect_to vote_path(svc: @valid_svc.svc)
      end
    else
      redirect_to @election
    end
  end

  def enter 
  # PRIVATE ELECTIONS PT 1:
  # Create a blank ValidSvc object 
  # so the user can enter the SVC they received
  
    @election = Election.find(params[:election_id])
    if @election.start_time > Time.now  
      flash[:error] = "This election has not started yet."
      redirect_to results_election_path(@election)
    elsif @election.finish_time < Time.now
      flash[:error] = "This election has already ended."
      redirect_to results_election_path(@election)
    else
      @valid_svc = ValidSvc.new
      @valid_svc.election = @election
    end
  end

  def confirm
  # PRIVATE ELECTIONS PT 2
  # Check whether the entered SVC is a valid one
    @election = Election.find(params[:election_id])
    svc = params[:valid_svc][:svc]
    if ValidSvc.exists?(svc: svc)
      redirect_to vote_path(svc)
    else
      flash[:error] = "That was not a valid SVC for this election. Try again."
      redirect_to enter_election_valid_svcs_path(@election)
    end
  end

end
