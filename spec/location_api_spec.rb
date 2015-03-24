ENV['RACK_ENV'] = 'test'

require 'json'
require 'rspec'
require 'rack/test'

require_relative '../LocationManagement/location_management_api'

describe 'Location Management API' do
  include Rack::Test::Methods

  # starts the LocationManagementAPI
  def app
    LocationManagementAPI.new
  end

  def body
    JSON.parse(last_response.body)
  end

  # sends a post request to add a new location
  it 'should add a location' do
    post '/locations', "name" => "New Location", "address" => "Salzburg 1234" 
    
    # should respond with status 201 and the added location with its ID
    expect(last_response.status).to eq(201)
    expect(body).to eq ({"name"=> "New Location","address"=> "Salzburg 1234","id"=> 1})
  end

  # sends a get request to get all locations from the service
  it 'should return all locations' do
    get '/locations'

    # should respond with status 200 and all locations
    expect(last_response).to be_ok
    expect(body).to eq [
    {
      "name"=> "Office Alexanderstraße",
      "address"=> "Alexanderstraße 45, 33853 Bielefeld, Germany",
      "id"=> 562
    },
    {
      "name"=> "Warehouse Hamburg",
      "address"=> "Gewerbestraße 1, 21035 Hamburg, Germany",
      "id"=> 563
    },
    {
      "name"=> "Headquarters Salzburg",
      "address"=> "Mozart Gasserl 4, 13371 Salzburg, Austria",
      "id"=> 568
    },
    {
      "name"=> "New Location",
      "address"=> "Salzburg 1234",
      "id"=> 1
    }]

  end

  # sends a delete request with ID
  it 'should delete a location' do
    delete '/locations/1'
    
    # should respond with 204 and an empty body
    # 204 is the status code for no body return (body false)
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq ""
  end
end
