class ValidSvcsController < ApplicationController


  def make
    @question = Question.find(params[:question_id])

    # for public elections
    unless @question.election.privacy
      @valid_svc = @question.valid_svcs.build
      @valid_svc.svc = SecureRandom.urlsafe_base64
      @valid_svc.save
      @vote = @question.votes.build
      @vote.svc = @valid_svc.svc
      @vote.bsn = SecureRandom.urlsafe_base64
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
    @question = Question.find(params[:question_id])
    @valid_svc = ValidSvc.new
    @valid_svc.question = @question
  end

  def confirm
    if ValidSvc.exists?(svc: params[:valid_svc][:svc])
      @question = Question.find(params[:question_id])
      @valid_svc = ValidSvc.find_by_svc(params[:valid_svc][:svc])
    # @vote = Vote.find_by_svc(@valid_svc.svc)
    # if @vote
    #   redirect_to @vote
    # else
      # if @valid_svc && @valid_svc.question == @question
      @vote = @question.votes.build
      @vote.svc = @valid_svc.svc
      @vote.bsn = SecureRandom.urlsafe_base64
      if @vote.save
        redirect_to @vote
      else
        flash[:error] = "This is a completely valid SVC, but we were unable to create your vote. Please try again"
        redirect_to enter_question_valid_svcs_path(@question)
      end
    else
      flash[:error] = "This is an invalid SVC"
      redirect_to enter_question_valid_svcs_path(@question)
    end
    # end
  end

end
