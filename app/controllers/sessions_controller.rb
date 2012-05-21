class SessionsController < ApplicationController
	
	def new
	end

	def create
		if params[:session][:email].include? "@"
			user = User.find_by_email(params[:session][:email])
		else
			user = User.find_by_handle(params[:session][:email])
		end

		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or user
		elsif user
			flash.now[:error] = 'Invalid login/password combination'
			render 'new'
		else
			flash.now[:error] = 'Invalid email or handle'
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to root_path
	end

end
