ENV['RACK_ENV'] = 'test'

require 'json'
require 'rspec'
require 'rack/test'

require_relative '../ItemTracking/item_tracking_api'

describe 'Item Tracking API' do
  include Rack::Test::Methods

  # starts the ItemTrackingAPI
  def app
    ItemTrackingAPI.new
  end

  def body
    JSON.parse(last_response.body)
  end

  # sends a post request to add a new item
  it 'should add an item' do
    post '/items', "name" => "New Item", "location" => 1234
    
    # should respond with status 201 and the added item with its ID
    expect(last_response.status).to eq(201)
    expect(body).to eq ({"name"=> "New Item","location"=> 1234,"id"=> 1})
  end

  # sends a get request to get all items from the service
  it 'should return all items' do
    get '/items'

    # should respond with status 200 and all items
    expect(last_response).to be_ok
    expect(body).to eq [
      {
        "name"=> "Johannas PC",
        "location"=> 562,
        "id"=> 456
      },
      {
        "name"=> "Johannas desk",
        "location"=> 562,
        "id"=> 457
      },
      {
        "name"=> "Lobby chair #1",
        "location"=> 563,
        "id"=> 501
      },
      {
        "name"=> "New Item",
        "location"=> 1234,
        "id"=> 1
      }]
  end

  # sends a delete request with ID
  it 'should delete an item' do
    delete '/items/1'
    
    # should respond with 204 and an empty body
    # 204 is the status code for no body return (body false)
    expect(last_response.status).to eq(204)
    expect(last_response.body).to eq ""
  end
end