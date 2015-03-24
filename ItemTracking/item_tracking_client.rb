require 'httparty'

class ItemTrackingClient
  include HTTParty
  base_uri 'http://localhost:9292'
end
