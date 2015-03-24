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

  context 'authorized with wrong credentials' do
    before do
      basic_authorize('paul', 'hitchcock')
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

  context 'correctly authorized' do
    before do
      basic_authorize('alfred', 'hitchcock')
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
