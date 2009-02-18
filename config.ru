require "minigems"
require "sinatra"

root_dir = File.dirname(__FILE__)

Sinatra::Application.default_options.merge!(
  :views    => File.join(root_dir, 'views'),
  :app_file => File.join(root_dir, 'streamslide.rb'),
  :run => false,
  :env => ENV['RACK_ENV'] ? ENV["RACK_ENV"].to_sym : "development"
)

set :raise_errors, true

require 'streamslide'
run Sinatra.application
