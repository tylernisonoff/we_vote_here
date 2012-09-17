class UsersController < ApplicationController
  respond_to :html, :json

  before_filter :signed_in_user, 
                only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update, :edit_password, :change_password]
  before_filter :admin_user,     only: :destroy
  
  def show
  	@user = User.find(params[:id])
    @elections = Election.find(:all, conditions: {user_id: params[:id]})
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to WeVoteHere!"
  
      redirect_to root_path
    
    else
      render 'new'
    end
  end

  def edit
  end

  def elections
    @user = User.find(params[:id])
    @elections = @user.elections
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

  def edit_password
    @user = User.find(params[:id])
  end

  def change_password
    @user = User.find(params[:id])

    if @user && @user.authenticate(params[:user][:old_password]) 
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save 
        flash[:success] = "Your password has been successfully changed!"
        sign_in @user
        redirect_to @user
      elsif params[:user][:password] != params[:user][:password_confirmation]
        flash[:notice] = "Your new password did not match the confirmation! You'll get it this time."
        redirect_to edit_password_user_path(@user)
      else
        flash[:error] = "Sorry, we were unable to change your password :("
        redirect_to edit_password_user_path(@user)
      end
    else 
      flash[:error] = "The old password you entered was invalid."
      redirect_to edit_password_user_path(@user)
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
