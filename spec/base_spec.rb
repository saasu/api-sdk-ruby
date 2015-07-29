require 'spec_helper'

describe Saasu::Base do
  describe "#all" do
    before do
      Saasu::Config.username = "user@saasu.com"
      Saasu::Config.password = "password"
      Saasu::Config.file_id  = 777

      mock_api_requests
    end

    specify do
      expect(Saasu::Test.all.count).to eq 1
    end    
  end

  private
  def mock_api_requests
    stub_request(:post, 'https://api.saasu.com/authorisation/token').
      with(body: { grant_type: 'password', scope: 'full', username: 'user@saasu.com', password: 'password' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { access_token: '12345', refresh_token: '67890', expires_in: 1000 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/tests?FileId=777').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { contacts: [{id: 1234, first_name: 'John'}] }.to_json, headers: {'Content-Type'=>'application/json'})
  end
end

class Saasu::Test < Saasu::Base
  allowed_methods :show, :index
  filter_by %W(Id FirstName)
end