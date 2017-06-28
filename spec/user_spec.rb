require 'spec_helper'

describe Saasu::User do
  before do
    Saasu::Config.username = "user@saasu.com"
    Saasu::Config.password = "password"
    Saasu::Config.file_id  = 777

    mock_api_requests
  end

  describe ".reset_password" do
    it 'uses the default scope when no scope specified' do
      query = Saasu::User.reset_password('user@saasu.com')
      expect(a_request(:post, "https://api.saasu.com/User/reset-password?FileId=777").with(body: '{"Username":"user@saasu.com"}'))
        .to have_been_made
    end
  end

  private
  def mock_api_requests
    stub_request(:post, 'https://api.saasu.com/authorisation/token').
      with(body: { grant_type: 'password', scope: 'full', username: 'user@saasu.com', password: 'password' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { access_token: '12345', refresh_token: '67890', expires_in: 1000 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:post, "https://api.saasu.com/User/reset-password?FileId=777").
      with(:body => "{\"Username\":\"user@saasu.com\"}",
           headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 12345', 'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'})
      .to_return(:status => 200, body: {}.to_json, :headers => {'Content-Type'=>'application/json'})
  end
end
