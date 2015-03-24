require 'sinatra'
require 'json'

require_relative '../ItemTracking/item_tracking_client'
require_relative '../LocationManagement/location_management_client'
require_relative '../USerManagement/user_management_client'

class ReportSystemAPI < Sinatra::Base

  get '/reports/by_location' do

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
  end

end