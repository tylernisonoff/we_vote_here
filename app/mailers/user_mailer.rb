class UserMailer < ActionMailer::Base
  default from: "wevotehere@gmail.com"

  def welcome_email(user)
    @user = user
    @url  = "http://wevotehere.herokuapp.com/"
    mail(to: user.email, subject: "Welcome to WeVoteHere!")
  end

  def election_email(email, election, svc=false)
  	@election = election
  	if svc
      @svc = svc
    end
  	mail(to: email, subject: "You are invited to vote at WeVoteHere!")
  end

end