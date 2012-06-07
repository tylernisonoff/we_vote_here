class VotesController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, ]


  def new
    @question = Question.find_by_id(params[:question_id])
  	@vote = @question.votes.build
    @vote.preferences.build
    @vote.preferences.each do |preference|
      preference.vote_id = @vote.id
    end
    respond with @vote
  end

  def create
  	@vote = Vote.new(params[:vote])
  	if @vote.save
  		flash[:success] = "Your vote has been recorded."
  		redirect_to root_path # redirect to election page
  	else
  		render 'new'
  	end
  end

  def edit
  end

  def update
  	if @vote.update_attributes(params[:vote])
  		flash[:success] = "Vote updated"
  		redirect_to root_path # redirect to election page
  	else
  		render 'edit'
  	end
  end

	private

		def correct_user
	  		@user = User.find(params[:id])
	  		redirect_to root_path unless @vote.user_id == current_user.id # redirect to election page
		end
end
