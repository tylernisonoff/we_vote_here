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
			render 'new'
		else
			flash.now[:error] = 'Invalid email'
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to root_path
	end

end
