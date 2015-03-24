ENV['RACK_ENV'] = 'test'

require 'json'
require 'rspec'
require 'rack/test'

require_relative '../ReportSystem/report_system_api'
require_relative '../LocationManagement/location_management_api'
require_relative '../ItemTracking/item_tracking_api'
require_relative '../UserManagement/middleware'
require_relative '../UserManagement/user_management'

describe 'Report System API' do
  include Rack::Test::Methods

  # starts all services with the config file
  before(:all) do
    @pid = Process.fork do
      Dir.chdir(File.expand_path("../../", __FILE__))
      exec "rackup -o 0.0.0.0 -p 9292 config.ru"
    end
    sleep 3
  end

  # kills the LocationManagementAPI and ItemTrackingAPI by console commands
  after(:all) do
    Process.kill "INT", @pid
    Process.wait
  end

  # APP = Rack::Builder.parse_file('config.ru').first

  def app
    ReportSystemAPI
  end

  def body
    JSON.parse(last_response.body)
  end

  before do
    basic_authorize('alfred', 'hitchcock')
  end

  # sends a get request to get all locations, with their appropriate items
  it 'should return an array of all locations, with all items in that location' do
    get '/reports/by_location'

    # should respond with status 200 and all locaitons items
    expect(last_response).to be_ok
    expect(body).to eq [
      {
        "name"=> "Office Alexanderstraße",
        "address"=> "Alexanderstraße 45, 33853 Bielefeld, Germany",
        "id"=> 562,
        "items"=> [
          {
            "name"=> "Johannas PC",
            "location"=> 562,
            "id"=> 456
          },
          {
            "name"=> "Johannas desk",
            "location"=> 562,
            "id"=> 457
          }]
      },
      {
        "name"=> "Warehouse Hamburg",
        "address"=> "Gewerbestraße 1, 21035 Hamburg, Germany",
        "id"=> 563,
        "items"=> [
          {
            "name"=> "Lobby chair #1",
            "location"=> 563,
            "id"=> 501
          }]
      },
      {
        "name"=> "Headquarters Salzburg",
        "address"=> "Mozart Gasserl 4, 13371 Salzburg, Austria",
        "id"=> 568
      }]
  end

end