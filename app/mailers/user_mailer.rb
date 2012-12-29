class UserMailer < ActionMailer::Base
  default from: "wevotehere@gmail.com"

  def election_email(email, election, svc=false)
  	@election = election
  	if svc
      @svc = svc
    end
  	mail(to: email, subject: "#{@election.user.pretty_name} asked you: #{@election.name}")
  end

end