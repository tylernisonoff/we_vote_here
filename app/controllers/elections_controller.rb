class ElectionsController < ApplicationController
  respond_to :html, :json

  before_filter :election_owner, only: [:edit, :update, :destroy, :add_voters, :update_voters]


	def new
		@election = Election.new
	end

  def show
    @election = Election.find(params[:id])
  end

	def create
  	@election = current_user.elections.build(params[:election])
    if @election.save
			flash[:success] = "Election created! Now make questions"
			redirect_to new_election_question_path(@election)
		else
			flash[:failure] = "Failure creating election :("
			render 'new'
		end
  end

  def destroy
  	@election.destroy
  	redirect_to root_path
  end

  def update
    if @election.update_attributes(params[:election])
      flash[:success] = "Election updated"
      redirect_to @election
    else
      render 'edit'
    end

    unless params[:election][:emails].blank? || !@election.questions.any?
      new_voters = @election.get_split_voters(params[:election][:emails])
      if @election.privacy
        @election.questions.each do |question|
          question.create_svcs_for_private(new_voters)
        end
      else
        @election.questions.each do |question|
          question.send_emails_for_public(new_voters)
        end
      end
    end
  end


  def index
    @elections = Election.all
  end

  def edit
  end

  def add_voters
    @election = Election.find(params[:id])
  end

   private

    def election_owner
      # puts "\n\n\n\n\n#{params}\n\n\n\n"
      @election = Election.find(params[:id])
      if current_user == @election.user
        return true
      else
        flash[:error] = "You cannot edit this election because you don't own it :/"
        redirect_to @election
      end
    end
end