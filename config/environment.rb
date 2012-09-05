# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WeVoteHere::Application.initialize!

WeVoteHere::Application.configure do

	config.action_mailer.delivery_method = :smtp

	# Configure Gmail SMTP Settings
	config.action_mailer.smtp_settings = {
    	:address              => "smtp.gmail.com",
    	:port                 => 587,
    	:domain               => 'wevotehere.herokuapp.com',
    	:user_name            => 'wevotehere@gmail.com',
    	:password             => 'condorcet89S',
    	:authentication       => 'plain',
    	:enable_starttls_auto => true  }

end
