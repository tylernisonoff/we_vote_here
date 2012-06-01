class ElectionsController < ApplicationController
  respond_to :html, :json


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
  			render 'new'
  		end
  	end

  def destroy
  	@election.destroy
  	redirect_to root_path
  end

  def update
    @election = Election.find(params[:id])

    respond_to do |format|
      if @election.update_attributes(params[:election])
        format.html { redirect_to(@election, :notice => 'Election was successfully updated.') }
        format.json { respond_with_bip(@election) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@election) }
      end
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