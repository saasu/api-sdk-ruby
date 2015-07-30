require 'spec_helper'

describe Saasu::Base do
  before do
    Saasu::Config.username = "user@saasu.com"
    Saasu::Config.password = "password"
    Saasu::Config.file_id  = 777

    mock_api_requests
  end

  describe "#all" do
    it 'returns records' do
      expect(Saasu::Test.all.count).to eq 1
    end
  end

  describe "#find" do
    it 'returns records' do
      expect(Saasu::Test.find(1)['id']).to eq 76543
      expect(Saasu::Test.find(2)['id']).to eq 98765
    end
  end

  describe "#where" do
    it 'validates filters' do
      expect{ Saasu::Test.where({ Name: 1 }) }.to raise_error
      expect{ Saasu::Test.where({ FirstName: 1 }) }.not_to raise_error
    end

    context 'method not implemented' do
      it 'raises an error' do
        expect{ Saasu::TestTwo.where({ Id: 1 }) }.to raise_error
      end
    end

    it 'returns records' do
      expect(Saasu::Test.where({ FirstName: 'Tester' }).first['id']).to eq 112233
    end
  end

  describe "#save" do
    it 'returns records' do
      record = Saasu::Test.new
      record['Name'] = 'Tester'
      expect(record.save).to be true
      expect(record.id).to eq 123
      expect(record.surname).to eq 'Spade'

      expect(a_request(:post, "https://api.saasu.com/test?FileId=777")).to have_been_made
    end
  end

  describe "#create" do
    it 'returns records' do
      record = Saasu::Test.create(GivenName: 'Jack')
      expect(record.id).to eq 765
      expect(record.surname).to eq 'Sparrow'

      expect(a_request(:post, "https://api.saasu.com/test?FileId=777")).to have_been_made
    end
  end

  describe "#delete" do
    it 'returns records' do
      record = Saasu::Test.create(GivenName: 'Jack')
      record.delete
      expect(record.id).to be_nil

      expect(a_request(:delete, "https://api.saasu.com/test/765?FileId=777")).to have_been_made
    end
  end

  describe "#validate_method_is_implemented_in_saasu_api" do
    it 'raises an exception when a method is not implemented in Saasu API' do
      expect { Saasu::Test.create({}) }.to raise_error
    end
  end

  private
  def mock_api_requests
    stub_request(:post, 'https://api.saasu.com/authorisation/token').
      with(body: { grant_type: 'password', scope: 'full', username: 'user@saasu.com', password: 'password' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { access_token: '12345', refresh_token: '67890', expires_in: 1000 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:post, 'https://api.saasu.com/test?FileId=777').
      with(body: { Name: 'Tester' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { Id: 123 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:post, 'https://api.saasu.com/test?FileId=777').
      with(body: { GivenName: 'Jack' },
      headers: {'Content-Type'=>'application/json', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { Id: 765 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, "https://api.saasu.com/test/123?FileId=777").
      with(headers: {'Authorization' => 'Bearer 12345', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { "Id" => 123, Surname: 'Spade'}.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, "https://api.saasu.com/test/765?FileId=777").
      with(headers: {'Authorization' => 'Bearer 12345', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { "Id" => 765, Surname: 'Sparrow'}.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:delete, "https://api.saasu.com/test/765?FileId=777").
      with(headers: {'Authorization' => 'Bearer 12345', 'X-Api-Version'=>'1.0'}).
      to_return(status: 200, body: { "StatusMessage" => "Ok" }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/tests?FileId=777').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { contacts: [{id: 1234, first_name: 'John'}] }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/test/1?FileId=777').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { id: 76543 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/test/2?FileId=777').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { id: 98765 }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/tests?FileId=777&FirstName=1').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { "Values" => [ ] }.to_json, headers: {'Content-Type'=>'application/json'})

    stub_request(:get, 'https://api.saasu.com/tests?FileId=777&FirstName=Tester').
      with(headers: {'X-Api-Version'=>'1.0', 'Authorization'=>'Bearer 12345'}).
      to_return(status: 200, body: { contacts: [{id: 112233}] }.to_json, headers: {'Content-Type'=>'application/json'})
  end
end

class Saasu::Test < Saasu::Base
  allowed_methods :show, :index, :update, :create, :destroy
  filter_by %W(Id FirstName)
end

class Saasu::TestTwo < Saasu::Base
  allowed_methods :show
end
