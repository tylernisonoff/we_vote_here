class UserMailer < ActionMailer::Base
  default from: "wevotehere@gmail.com"

  def welcome_email(user)
    @user = user
    @url  = "http://wevotehere.herokuapp.com/"
    mail(to: user.email, subject: "Welcome to My Awesome Site")
  end

  def question_email(email, question, svc)
  	@email = email
  	@question = question
  	@svc = svc
  	mail(to: @email, subject: "You are invited to vote at WeVoteHere!")
  end



end