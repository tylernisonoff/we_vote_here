class VotesController < ApplicationController
  respond_to :html, :json

  # before_filter :signed_in_user, only: [:index, :edit, :update]


  def new
    @question = Question.find_by_id(params[:question_id])
  	@vote = @question.votes.build
    @vote.question_id = @question.id
    @question.candidates.each do |candidate|
      @preference = @vote.preferences.build(candidate_id: candidate.id)
    end
    respond_with @vote
  end

  def create
    @question = Question.find_by_id(params[:question_id])
  	@vote = @question.votes.build(params[:vote])
  	if @vote.save
  		flash[:success] = "Your vote has been recorded."
  		redirect_to root_path # redirect to election page
  	else
  		render 'new'
  	end
  end

  # def update
  # 	if @vote.update_attributes(params[:vote])
  # 		flash[:success] = "Vote updated"
  # 		redirect_to root_path # redirect to election page
  # 	else
  # 		render 'edit'
  # 	end
  # end

  def show
    @vote = Vote.find(params[:id])
  end

  def sort
    params[:preferences].each_with_index do |id, index|
      @vote.preferences.update(['position=?', index+1], ['id=?', id])
    end
    render nothing: true
  end

	private

		def correct_user
	  		@user = User.find(params[:id])
	  		redirect_to root_path unless @vote.user_id == current_user.id # redirect to election page
		end
end
