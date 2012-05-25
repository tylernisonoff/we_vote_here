class ElectionsController < ApplicationController
  
	def new
		@election = Election.new
    @election.candidates.build
    @election.candidates.each do |candidate|
      candidate.election_id = @election.id
    end
	end

  def show
    @election = Election.find(params[:id])
    @candidates = @election.candidates
  end

	def create
  		@election = current_user.elections.build(params[:election])
      if @election.save
  			flash[:success] = "Election created!"
  			redirect_to root_path
  		else
  			flash[:failure] = "Failure creating election :("
  			redirect_to root_path
  		end
  	end

  def destroy
  	@election.destroy
  	redirect_to root_path
  end

  def update
    if @election.update_attributes(params[:election])
      flash[:success] = "Election updated"
    else
      redirect_back_or root_path
    end
  end


  def index
    @elections = Election.all
  end

   private

    def election_owner
      @user = User.find(params[:id])
      redirect_to(root_path) unless @user == Election.user_id
    end
end