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
    if @group.save
			flash[:success] = "Group created! Now make questions"
			redirect_to new_group_question_path(@group)
		else
			flash[:failure] = "Failure creating group :("
			render 'new'
		end
  end

  def destroy
  	@group.destroy
  	redirect_to root_path
  end

  def update
    if @group.update_attributes(params[:group])
      flash[:success] = "Group updated"
      redirect_to @group
    else
      render 'edit'
    end

    unless params[:group][:emails].blank? || !@group.questions.any?
      new_voters = @group.get_split_voters(params[:group][:emails])
      if @group.privacy
        @group.questions.each do |question|
          question.create_svcs_for_private(new_voters)
        end
      else
        @group.questions.each do |question|
          question.send_emails_for_public(new_voters)
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
    @group = Group.find(params[:id])
  end

   private

    def group_owner
      # puts "\n\n\n\n\n#{params}\n\n\n\n"
      @group = Group.find(params[:id])
      if current_user == @group.user
        return true
      else
        flash[:error] = "You cannot edit this group because you don't own it :/"
        redirect_to @group
      end
    end

end