require 'sinatra/base'

class UserManagement < Sinatra::Base
  get '/user' do
    status 200
  end
end
