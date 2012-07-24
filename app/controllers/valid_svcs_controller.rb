class ValidSvcsController < ApplicationController


  def make
  # PUBLIC ELECTIONS
    @question = Question.find(params[:question_id])

    # for public elections
    unless @question.election.privacy
      @vote = @question.votes.build
      @vote.assign_svc
      @vote.assign_bsn
      if @vote.save
        redirect_to @vote
        flash[:success] = "Cast your vote!"
      else
        flash[:error] = "There has been an error creating your SVC"
      end
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
    if ValidSvc.exists?(svc: params[:valid_svc][:svc])
      @question = Question.find(params[:question_id])
      @vote = @question.votes.build
      @vote.assign_svc(params[:valid_svc][:svc])
      redirect_to @vote
    else
      flash[:error] = "This is an invalid SVC"
      redirect_to enter_question_valid_svcs_path(@question)
    end
  end

  def exit
    puts "\n\n\n\n\n\n\n\n\n#{params}\n\n\n\n\n\n\n\n"
  end

end
