class QuestionsController < ApplicationController
	respond_to :html, :json

	def new
    @election = Election.find_by_id(params[:election_id])
    @question = @election.questions.build
    @question.candidates.build
    @question.candidates.each do |candidate|
      candidate.question_id = @question.id
    end
    respond_with @question
	end

	def create
    @election = Election.find(params[:election_id])
		@question = @election.questions.build(params[:question])
		if @question.save
			flash[:success] = "Question saved"
      if params[:commit] == "Save"
			  redirect_to root_path
      elsif params[:commit] == "Add another question"
        redirect_to new_election_question_path(@question.election)
		  end
    else
			flash[:failure] = "Failed to save question"
		end
	end

	def edit
		@question = Question.find(params[:id])
	end

	def show
    @question = Question.find(params[:id])
  end

  def destroy
  	@question.destroy
  	redirect_to root_path
  end

  def questions
    @election = Election.find(params[:id])
    @questions = @election.questions
  end

  def update
    respond_to do |format|
      if @question.update_attributes(params[:question])
        #format.html { redirect_to(@question, notice: 'Question was successfully updated.') }
        format.json { respond_with_bip(@question) }
      else
        #format.html { render action: "edit" }
        format.json { respond_with_bip(@question) }
      end
    end
  end

   private

    def question_owner
      @user = User.find(params[:id])
      redirect_to(root_path) unless @user == Question.user_id
    end
end
