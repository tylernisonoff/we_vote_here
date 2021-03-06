class UsersController < ApplicationController
  respond_to :html, :json

  before_filter :authenticate_user!
  before_filter :signed_in_user, 
                only: [:index, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update, :edit_password, :change_password, :edit_password, :add_emails, :save_emails]
  before_filter :group_follower, only: [:unfollow_group]

  
  def show
  	@user = User.find(params[:id])
  end

  def groups
    @user = User.find(params[:id])
    @groups = @user.groups
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"
    redirect_to users_path
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def add_emails
    @user = User.find(params[:id])
  end

  def save_emails
    @user = User.find(params[:id])
    @user_emails = params[:user][:user_emails].split(/[\s,]+/)
    success = true
    @user_emails.each do |email|
      unless ValidEmail.exists?(email: email)
        @user_email = ValidEmail.new
        @user_email.voter_id = @user.voter.id
        @user_email.email = email
        unless @user_email.save
          flash[:error] = "We were unable to add the email '#{email}'"
          success = false
        end
      else
        valid_email = ValidEmail.find_by_email(email)
        voter = valid_email.voter
        if voter.user && voter.user != @user
          flash[:error] = "The email '#{email}' already belongs to someone else. Strange."
          success = false
        else
          valid_email.voter_id = @user.voter.id
          valid_email.save
          voter.destroy # delete redundant voter
        end
      end
    end
    if success
      flash[:success] = "We have successfully added all of your emails!"
    end
    redirect_to emails_user_path(@user)
  end

  def make_primary_email
    @user = User.find(params[:id])
    @new_primary_email = UserEmail.find(params[:user_email_id])
    @user.email = @new_primary_email.email
    if @user.save
      flash[:success] = "Primary email successfully updated!"
      sign_in @user
    else
      flash[:error] = "Sorry, we could not update your email."
    end
    redirect_to emails_user_path(@user)
  end

  def unfollow_group
    @user = User.find(params[:id])
    @group = Group.find(params[:group_id])
    success = true  
    @voter = @user.voter
    @membership = Membership.find(:first, conditions: {group_id: @group.id, voter_id: @voter.id})
    if @membership.destroy
      flash[:success] = "We successfully removed you from this group!"
    else
      flash[:error] = "We were unable to unfollow this group."
    end
    redirect_back_or root_path
  end

  def emails
    @user = User.find(params[:id])
    @voter = Voter.find(:first, conditions: {user_id: @user.id})
    @user_emails = ValidEmail.find(:all, conditions: {voter_id: @voter.id})
  end

  def index
    @users = User.all
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user == @user
    end

    def group_follower
      @user = User.find(params[:id])
      @voter = @user.voter
      @group = Group.find(params[:group_id])
      return Membership.exists?(group_id: @group.id, voter_id: @voter.id)
    end

    def signed_in_user
      unless user_signed_in?
        flash[:error] = "You must be signed in to see this!"
        redirect_back_or new_user_session_path
        return false
      else
        return true
      end
    end

end
