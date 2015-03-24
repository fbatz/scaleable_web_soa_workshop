require 'httparty'

class LocationManagementClient
  include HTTParty
  base_uri 'http://localhost:9494'
end
