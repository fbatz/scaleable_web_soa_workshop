require 'rubygems'
require 'bundler'
Bundler.require

set :port=> 8000

app = Rack::Builder.new do
    map "/user" do
      use Middleware
      run UserManagement.new
      p 'UM started'
    end
    map "/items" do
      run ItemTrackingAPI.new
      p 'Item started'
    end
    map "/locations" do
     run LocationManagementAPI.new
     p 'Locs started'
    end

end

run app