require 'rubygems'
require 'bundler'
Bundler.require

require './ItemTracking/item_tracking_api'
require './ReportSystem/report_system_api'
require './LocationManagement/location_management_api'
require './UserManagement/user_management'
require './UserManagement/middleware'

user_management = Rack::Builder.new {
      use Middleware
      run UserManagement.new
    }

run Rack::Cascade.new [
	user_management,
	ItemTrackingAPI, 
	ReportSystemAPI, 
	LocationManagementAPI]
