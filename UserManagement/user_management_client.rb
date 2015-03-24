require 'httparty'

class UserManagementClient
  include HTTParty
  base_uri 'http://localhost:9292'
end
