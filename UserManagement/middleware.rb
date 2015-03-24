require 'base64'
require 'rack'

class Middleware

  def initialize(app)
    @app = app    
  end

  def call(env)
    if env['HTTP_AUTHORIZATION']
        username, password = Base64.decode64(env['HTTP_AUTHORIZATION'].gsub(/^Basic /, '')).split(':')
        if username == 'alfred' && password == 'hitchcock'
          @app.call(env) #200 User Management System passing exact HTTP Basic Auth header to Report System 
        else
          [403, {'Content-Type' => 'text/plain'}, ['Wrong Credentials']]
        end
    else
      [403, {'Content-Type' => 'text/plain'}, ['Not Authorizied']]
    end
  end
end

# User  Password
# wanda partyhard2000
# paul  thepanther
# anne  flytothemoon
