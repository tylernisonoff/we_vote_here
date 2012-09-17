class UserMailer < ActionMailer::Base
  default from: "wevotehere@gmail.com"

  def welcome_email(user)
    @user = user
    @url  = "http://wevotehere.herokuapp.com/"
    mail(to: user.email, subject: "Welcome to WeVoteHere!")
  end

  def private_question_email(email, question, svc)
  	@question = question
  	@svc = svc
  	mail(to: email, subject: "You are invited to vote at WeVoteHere!")
  end

  def public_question_email(email, question)
    @question = question
    mail(to: email, subject: "You are invited to vote at WeVoteHere!")
  end



end