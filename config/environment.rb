# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WeVoteHere::Application.initialize!

WeVoteHere::Application.configure do

    config.action_mailer.default_url_options = { :host => 'myapp.herokuapp.com' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    # config.action_mailer.raise_delivery_errors = false
    config.action_mailer.default :charset => "utf-8"
    
    config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "wevotehere.herokuapp.com",
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: ENV["GMAIL_USERNAME"],
      password: ENV["GMAIL_PASSWORD"]
    }

end
