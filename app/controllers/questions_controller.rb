class QuestionsController < ApplicationController
  require 'csv'
  respond_to :html, :json

	def new
    @election = Election.find_by_id(params[:election_id])
    @question = @election.questions.build
    @question.choices.build
    @question.choices.each do |choice|
      choice.question_id = @question.id
    end
    respond_with @question
	end

	def create
    @election = Election.find(params[:election_id])
		@question = @election.questions.build(params[:question])
		if @question.save
			flash[:success] = "Question saved"
      if params[:commit] == "Save"
			  redirect_to @election
      elsif params[:commit] == "Add another question"
        redirect_to new_election_question_path(@question.election)
		  end
    else
			flash[:failure] = "Failed to save question"
		end

    # If the election is private, then create SVCs
    # This also sends an email to every valid email with their SVC
    if @election.privacy  
      @question.create_svcs
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

  def index
    @elections = Election.all
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

  def export_mov_to_csv
    @question = Question.find(params[:id])
    @choice_names = @question.choice_name_array
    @adj_choice_names = [0] + @choice_names
    
    @choice_ids = @question.choice_id_array
    @mov = @question.get_mov

    filename ="election_#{@question.election.name}_question_#{@question.name}"
    
    csv_data = CSV.generate do |csv|
      @adj_choice_names.each_with_index do |choice_name, index|
        if index == 0
          csv << @adj_choice_names
        else  
          add_to_csv = [choice_name]
          @choice_ids.each do |choice_id|
            # puts "\n\n\n\n\n\n#{@mov[@choice_ids[index]][choice_id]}\n\n\n\n\n"
            add_to_csv.push(@mov[@choice_ids[index-1]][choice_id])
          end
          csv << add_to_csv
        end
      end
    end

    send_data csv_data,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: "attachment; filename=#{filename}.csv"
  end

   private

    def question_owner
      @user = User.find(params[:id])
      redirect_to(root_path) unless @user == Question.user_id
    end
end
