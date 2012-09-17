module UsersHelper

  # Returns the Gravatar (http://gravatar.com/) for the given user.

  def edit_user_condition(current_user, user)
  	current_user == user
  end
end