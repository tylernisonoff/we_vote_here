class VotesController < ApplicationController
  respond_to :html, :json

  # before_filter :signed_in_user, only: [:index, :edit, :update]


  # def new
  #   @question = Question.find_by_id(params[:question_id])
  # 	@vote = @question.votes.build
  #   @vote.question_id = @question.id
  #   @question.candidates.each do |candidate|
  #     @preference = @vote.preferences.build(candidate_id: candidate.id)
  #   end
  #   respond_with @vote
  # end

  # def create
  # end

  # def enter
  #   if true #Svc.exists?(svc1: params[:svc1])
      
  #     unless Vote.exists?(svc: params[:svc], question_id: params[:question_id])
  #       @question = Question.find_by_id(params[:question_id])
  #       @vote = @question.votes.build
  #       @vote.svc1 = params[:svc1]
  #       if @vote.save
  #         flash[:success] = "Your vote has been recorded."
  #         # redirect_to root_path # redirect to election page
  #       else
  #         render 'new'
  #       end
  #     else
  #       @vote = Vote.find_by_question_id_and_svc1(params[:question_id], params[:svc1])
  #     end
  #     render nothing: true
  #   else
  #     print "\n\n\n\n\n\n\n\nSVC ISN'T VALID\n\n\n\n\n\n\n\n"
  #   end
  # end

  # def update
  # 	if @vote.update_attributes(params[:vote])
  # 		flash[:success] = "Vote updated"
  # 		redirect_to root_path # redirect to election page
  # 	else
  # 		render 'edit'
  # 	end
  # end

  def show
    @vote = Vote.find_by_svc(params[:id])
  end

	private

		def correct_user
	  		@user = User.find(params[:id])
	  		redirect_to root_path unless @vote.user_id == current_user.id # redirect to election page
		end
end
