# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
WeVoteHere::Application.initialize!

WeVoteHere::Application.configure do

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    # config.action_mailer.raise_delivery_errors = false
    config.action_mailer.default :charset => "utf-8"

end
