require 'sinatra'
require 'json'

require_relative '../ItemTracking/item_tracking_client'
require_relative '../LocationManagement/location_management_client'
require_relative '../USerManagement/user_management_client'

class ReportSystemAPI < Sinatra::Base

  get '/reports/by_location' do

    # creates a request header
    headers = {}
    headers["AUTHORIZATION"] = env["HTTP_AUTHORIZATION"] if env["HTTP_AUTHORIZATION"]
    headers["ACCEPT"] = env["HTTP_ACCEPT"] if env["HTTP_ACCEPT"]

    # sends a get request to the UserManagement with authorization information in the header
    user_response = UserManagementClient.get("/user", headers: headers)

    # checks if the authorization with the user management is valid
    if user_response.code == 200
        # sends a get request to the ItemTrackingAPI, to get all items
        items = ItemTrackingClient.get("/items").body
        items = JSON.parse(items)

        # sends a get request to the LocationManagementAPI, to get all locations
        locations = LocationManagementClient.get("/locations").body
        locations = JSON.parse(locations)

        # combines data from the location and item tracking system 
        # each location object has a key items which holds an array of all items in that location 
        locations.map do |location|
          items_by_location = items.select{|e| e['location'] == location['id'].to_i}
          if items_by_location.length > 0
            location['items'] = items_by_location
          end
        end

        # returns an array of all locations with their appropriate items
        locations.to_json
    else
        # no valid authorization 
        # returns user management response
        [user_response.code, {'Content-Type' => 'text/plain'}, user_response.body]
    end
  end

end