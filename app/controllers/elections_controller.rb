class ElectionsController < ApplicationController
  
	def new
		@election = Election.new
    2.times do
      candidate = @election.candidates.build
    end
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
  	redirect_back_or root_path
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
