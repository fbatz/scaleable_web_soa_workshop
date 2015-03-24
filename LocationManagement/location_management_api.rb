require 'grape'

class LocationManagementAPI < Grape::API

  # some default locations are saved in locations, because there is no DB
  # only for testing purpose
  locations = [
    {
      "name": "Office Alexanderstraße",
      "address": "Alexanderstraße 45, 33853 Bielefeld, Germany",
      "id": 562
    },
    {
      "name": "Warehouse Hamburg",
      "address": "Gewerbestraße 1, 21035 Hamburg, Germany",
      "id": 563
    },
    {
      "name": "Headquarters Salzburg",
      "address": "Mozart Gasserl 4, 13371 Salzburg, Austria",
      "id": 568
    }
  ]

  location_id = 0

  format :json

  # requires name and address, they have to be part of the request
  params do
    requires :name, type: String, desc: "Your name."
    requires :address, type: String, desc: "Your address."
  end
  post '/locations' do
    # creates a new location element with a new id
    locations.push({
      "name"=> params[:name],
      "address"=> params[:address],
      "id"=> location_id += 1
    })
    # returns HTTP status 201 with a complete JSON representation of the location (including the ID) 
    locations.last
  end
  
  # returns status 200 and all locations
  get '/locations' do
    locations
  end

  # DELETE Request
  delete '/locations/(:id)' do
    # checks if the ID exists
    if locations.find{|e| e['id'] == params[:id].to_i}
      # deletes the location specified by the ID
      locations.delete_if{|e| e['id'] == params[:id].to_i}
      # returns status 200 and an empty body
      body false
    else
      # returns status 404 if the supplied ID does not exist.
      error!('404 ID does not exist.', 404)
    end
  end

end
