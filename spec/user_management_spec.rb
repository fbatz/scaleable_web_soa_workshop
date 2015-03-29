require 'rack/test'
require_relative '../UserManagement/middleware'
require_relative '../UserManagement/user_management'

describe UserManagement do
  include Rack::Test::Methods

  let(:app) {
    Rack::Builder.new {
      use Middleware
      run UserManagement.new
    }
  }

  # sends a get request without authorization credentials
  context 'unauthorized' do
    describe "/user" do
      before do
        get '/user'
      end

      it "returns status 403" do
        expect(last_response.status).to be 403
      end
    end
  end

  # sends a get request with wrong authorization credentials
  context 'authorized with wrong credentials' do
    before do
      basic_authorize('wrong', 'credentials')
    end

    describe "/user" do
      before do
        get '/user'
      end

      it "returns status 403" do
        expect(last_response.status).to be 403
      end
    end
  end

  # sends a get request with right authorization credentials
  context 'correctly authorized' do
    before do
      basic_authorize('paul', 'thepanther')
    end

    describe "/user" do
      before do
        get '/user'
      end

      it "returns status 200" do
        expect(last_response.status).to be 200
      end
    end
  end

end
