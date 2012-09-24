class SessionsController < ApplicationController
	
	def new
	end

	def create
		email = UserEmail.find_by_email(params[:session][:email])
		user = email.user

		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or root_path
		elsif user
			flash.now[:error] = 'Invalid login/password combination'
			redirect_back_or signin_path
		else
			flash.now[:error] = 'Invalid email'
			redirect_back_or signin_path
		end
	end

	def destroy
		sign_out
		redirect_to root_path
	end

end
