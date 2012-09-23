class ValidSvcsController < ApplicationController


  def make
  # PUBLIC ELECTIONS
    @question = Question.find(params[:question_id])

    # for public groups
    unless @question.group.privacy
      @valid_svc = ValidSvc.new
      @valid_svc.question = @question
      @valid_svc.assign_valid_svc
      @valid_svc.save
      redirect_to vote_path(svc: @valid_svc.svc)
    else
      redirect_to @question
    end
  end

  def enter 
  # PRIVATE ELECTIONS PT 1:
  # Create a blank ValidSvc object 
  # so the user can enter the SVC they received
  
    @question = Question.find(params[:question_id])
    @valid_svc = ValidSvc.new
    @valid_svc.question = @question
  end

  def confirm
  # PRIVATE ELECTIONS PT 2
  # Check whether the entered SVC is a valid one
    @question = Question.find(params[:question_id])
    svc = params[:valid_svc][:svc]
    if ValidSvc.exists?(svc: svc)
      redirect_to vote_path(svc)
    else
      flash[:error] = "That was not a valid SVC for this election. Try again."
      redirect_to enter_question_valid_svcs_path(@question)
    end
  end

end
