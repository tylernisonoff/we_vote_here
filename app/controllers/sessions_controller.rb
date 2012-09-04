class SessionsController < ApplicationController
	
	def new
	end

	def create
		login = params[:session][:handle_or_email]
		if contains_at(login)
			user = User.find_by_email(login)
		else
			user = User.find_by_handle(login)
		end

		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or root_path
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
