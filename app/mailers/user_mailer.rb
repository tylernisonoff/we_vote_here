class UserMailer < ActionMailer::Base
  default from: "wevotehere@gmail.com"

  def welcome_email(user)
    @user = user
    @url  = "http://wevotehere.herokuapp.com/"
    mail(to: user.email, subject: "Welcome to WeVoteHere!")
  end

  def election_email(email, election, svc=false)
  	@election = election
    owner = @election.group.user
  	if svc
      @svc = svc
    end
  	mail(to: email, subject: "#{owner.pretty_name} invited you to vote in the election: #{@election.name}")
  end

end