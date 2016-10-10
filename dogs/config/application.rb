require_relative 'boot'

require 'rails/all'



# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dogs
	class Application < Rails::Application
		config.middleware.insert_before 0, Rack::Cors do
			allow do
				origins '*'
				resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :delete, :post]
			end
		end
	end
end
