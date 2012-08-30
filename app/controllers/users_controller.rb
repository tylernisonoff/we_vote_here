class UsersController < ApplicationController
  respond_to :html, :json

  before_filter :signed_in_user, 
                only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update, :change_password]
  before_filter :admin_user,     only: :destroy
  
  def show
  	@user = User.find(params[:id])
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to WeVoteHere!"

      # Tell the UserMailer to send a welcome Email after save
      UserMailer.welcome_email(@user).deliver

      format.html { redirect_to(@user, :notice => 'User was successfully created.') }
      format.json { render :json => @user, :status => :created, :location => @user }
  
      redirect_to root_path
    
    else
      render 'new'
      # format.html { render :action => "new" }
      # format.json { render :json => @user.errors, :status => :unprocessable_entity }
    end
  end

  def edit
    @user = User.find(params[:id])
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
