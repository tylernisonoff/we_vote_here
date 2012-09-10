class ValidSvcsController < ApplicationController


  def make
  # PUBLIC ELECTIONS
    @question = Question.find(params[:question_id])

    # for public elections
    unless @question.election.privacy
      @vote = @question.votes.build
      @vote.assign_svc
      @vote.assign_bsn
      @vote.save
      redirect_to vote_path(@vote.svc)
    else
      redirect_to @question
    end
  end

  def enter 
  # PRIVATE ELECTIONS PT 1
    @question = Question.find(params[:question_id])
    @valid_svc = ValidSvc.new
    @valid_svc.question = @question
  end

  def confirm
  # PRIVATE ELECTIONS PT 2
    @question = Question.find(params[:question_id])
    if ValidSvc.exists?(svc: params[:valid_svc][:svc])
      @vote = @question.votes.build
      @vote.assign_svc(params[:valid_svc][:svc])
      @vote.assign_bsn
      @vote.save
      redirect_to vote_path(@vote.svc)
    else
      flash[:error] = "That was not a valid SVC for this election. Try again"
      redirect_to enter_question_valid_svcs_path(@question)
    end
  end

  def exit
  end

end
