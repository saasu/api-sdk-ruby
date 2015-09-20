require 'spec_helper'

describe Saasu::Search do
  before do
    Saasu::Config.username = "user@saasu.com"
    Saasu::Config.password = "password"
    Saasu::Config.file_id  = 777

    mock_api_requests
  end

  describe ".search" do
    it 'uses the default scope when no scope specified' do
      query = Saasu::Search.new(keywords: 'Customer')
      expect(query.perform).to eq({ contacts: 8, invoices: 10, items: 15 })
      expect(a_request(:get, "https://api.saasu.com/search?FileId=777&IncludeSearchTermHighlights=false&Keywords=Customer&Scope=All"))
        .to have_been_made
    end
  end

  private
  def mock_api_requests
    stub_request(:post, 'https://api.saasu.com/authorisation/token').
      with(body: { grant_type: 'password', scope: 'full', username: 'user@saasu.com', password: 'password' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { access_token: '12345', refresh_token: '67890', expires_in: 1000 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, "https://api.saasu.com/search?FileId=777&IncludeSearchTermHighlights=false&Keywords=Customer&Scope=All").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Authorization'=>'Bearer 12345', 'User-Agent'=>'Faraday v0.9.1', 'X-Api-Version'=>'1.0'}).
      to_return(:status => 200, body: search_results.to_json, :headers => {'Content-Type'=>'application/json'})
  end

  def search_results
    {
      "TotalContactsFound" => 8,
      "TotalTransactionsFound" => 10,
      "TotalInventoryItemsFound" => 15
    }
  end
end
