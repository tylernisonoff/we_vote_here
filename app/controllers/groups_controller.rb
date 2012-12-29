class GroupsController < ApplicationController
  respond_to :html, :json

  before_filter :group_owner, only: [:edit, :update, :destroy, :add_voters, :update_voters]

	def new
		@group = Group.new
	end

  def show
    @group = Group.find(params[:id])
  end

	def create
  	@group = current_user.groups.build(params[:group])
    if @group.election_id
      @election = Election.find(@group.election_id)
      @group.name = "Additional voters for election: \##{@election.id}"
      inc = Inclusion.new
      inc.election_id = @group.election_id
      inc.group = @group
      inc.save
    end
    if @group.save && @group.save_emails(params[:group][:emails])
			flash[:success] = "Group created!"
			redirect_to @group
		else
			flash[:failure] = "Failure creating group :("
			render 'new'
		end
  end

  def destroy
    if @group.destroy
      flash[:success] = "Successfully destroyed group."
      redirect_to root_path
    else
      flash[:error] = "We were unable to destroy this group."
      redirect_to @group
    end
  end

  def update
    if @group.update_attributes(params[:group]) && @group.save_emails(params[:group][:emails])
      flash[:success] = "Group updated"
      unless @group.election_id
        redirect_to @group
      else
        @election = Election.find(@group.election_id)
        redirect_to @election
      end
    else
      render 'edit'
    end

    unless params[:group][:emails].blank? || !@group.elections.any?
      new_voters = @group.get_split_voters(params[:group][:emails])
      @group.elections.each do |election|
        if election.finish_time > Time.now
          election.send_election_emails(new_voters)
        end
      end
    end
  end


  def index
    @groups = Group.all
  end

  def edit
  end

  def add_voters
    if params[:election_id]
      @election = Election.find(params[:election_id])
      if Group.exists?(election_id: @election.id)
        @group = Group.find(:first, conditions: {election_id: @election.id})
      else
        @group = Group.new
        @group.election_id = @election.id
        @group.user = @election.user
        @group.name = "Additional voters for election \##{@election.id}"
        @group.save
        @inclusion = Inclusion.new
        @inclusion.group_id = @group.id
        @inclusion.election_id = @election.id
        @inclusion.save
      end
    else
      @group = Group.find(params[:group_id])
    end
  end

   private

    def group_owner
      if params[:id] 
        @group = Group.find(params[:id])
        if current_user == @group.user
          return true
        else
          flash[:error] = "You cannot edit this group because you don't own it :/"
          redirect_to @group
        end
      else
        if params[:election_id]
          @election = Election.find(params[:election_id])
          if current_user == @election.user
            return true
          else
            flash[:error] = "You cannot edit this election because you don't own it :/"
            redirect_to @election
          end
        end
      end
    end

end