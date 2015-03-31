require 'rubygems'
require 'bundler'
Bundler.require

require './UserManagement/user_management'
require './UserManagement/middleware'

user_management = Rack::Builder.new {
      use Middleware
      run UserManagement.new
    }

run	user_management
