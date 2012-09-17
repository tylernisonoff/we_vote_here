class QuestionsController < ApplicationController
  require 'csv'
  respond_to :html, :json

  before_filter :election_owner, only: [:new, :create, :edit, :update, :destroy]

  # eventually use this after I figure out how to make sessions with CSVs
  # before_filter :can_view, only: [:export_mov_to_csv, :export_votes_to_csv, :results, :show, :index]
  
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
      @question.create_svcs_for_private
    else
      @question.send_emails_for_public
    end
	end

	def edit
		# @question = Question.find(params[:id])
	end

	def show
    @question = Question.find(params[:id])
  end

  def destroy
  	@question.destroy
  	redirect_to root_path
  end

  def index
    if params[:election_id]
      @election_id = params[:election_id]
      @questions = Question.find(:all, conditions: {election_id: params[:election_id]})
    else
      @questions = Question.all
    end
  end

  def update
    if @question.update_attributes(params[:question])
      flash[:success] = "Question updated"
      redirect_to @question
    else
      render 'edit'
    end
  end

  def results
    @question = Question.find(params[:id])
    @results_array = @question.choice_name_array(true)
  end

  def export_mov_to_csv
    # future: only allow certain calls when dynamic is on
    
    @question = Question.find(params[:id])
    @mov = @question.get_mov

    if params[:adjusted] == "1"
      sorted = true
    else
      sorted = false
    end

    if sorted
      filename ="adjusted_mov_for_#{@question.name}"
    else
      filename ="regular_mov_for_#{@question.name}"
    end

    @choice_names = @question.choice_name_array(sorted)
    @choice_ids = @question.choice_id_array(sorted)
    
    csv_data = CSV.generate do |csv|
      csv << (["Choice"] + @choice_names)
      @choice_names.each_with_index do |choice_name, index|
        add_to_csv = [choice_name]
        @choice_ids.each do |choice_id|
          add_to_csv.push(@mov[@choice_ids[index]][choice_id])
        end
        csv << add_to_csv
      end
    end

    send_data csv_data,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: "attachment; filename=#{filename}.csv"
  end

  def export_votes_to_csv
    @question = Question.find(params[:id])
    @votes_hash = @question.get_active_votes_hash

    @choice_names = @question.choice_name_array
    @choice_ids = @question.choice_id_array
    filename ="active_votes_for_#{@question.name}"

    csv_data = CSV.generate do |csv|
      csv << (["BSN"] + @choice_names)
      @votes_hash.each do |vote_id, vote_hash|  
        add_to_csv = [vote_id]
        @choice_ids.each do |choice_id|
          add_to_csv.push(vote_hash[choice_id])
        end
        csv << add_to_csv
      end
    end

    send_data csv_data,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: "attachment; filename=#{filename}.csv"
  end

   private

    def election_owner
      if params[:election_id]
        if Election.exists?(params[:election_id])
          @election = Election.find(params[:election_id])
          if current_user == @election.user
            return true
          else
            flash[:error] = "You cannot edit this question because you don't own it :/"
            redirect_back_or root_path
          end
        else
          flash[:error] = "Sorry, that election doesn't exist"
        end
      elsif params[:id]
        if Question.exists?(params[:id])
          @question = Question.find(params[:id])
          if current_user == @question.election.user
            return true 
          else
            flash[:error] = "You cannot edit this question because you don't own it :/"
            redirect_back_or root_path
          end
        else
          flash[:error] = "Sorry, that question doesn't exist"
        end
      else
        flash[:error] = "You cannot edit this question because we're not sure if you own it :/"
        redirect_back_or root_path
      end
    end

    def can_view
      question = Question.find(params[:id])
      if !question.election.privacy || ValidSvc.exists?(svc: params[:svc])
        return true
      else
        flash[:error] = "You need a valid SVC to do this."
        redirect_back_or root_path
        return false
      end
    end
end
