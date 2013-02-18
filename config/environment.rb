# Load the rails application
require File.expand_path('../application', __FILE__)

require File.expand_path("#{Rails.root}/lib/postgre_json_type.rb")

# Initialize the rails application
Campaings::Application.initialize!
