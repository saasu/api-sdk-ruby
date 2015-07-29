require 'faraday'
require 'faraday_middleware'

module Saasu
  module Auth
    extend self

    def authenticate
      Saasu::Client.connection.authorization :Bearer, token
    end

    private
    def token_expired?
      @token_expiry ||= Date.yesterday
      @token_expiry < DateTime.now
    end

    def token
      if @access_token && !token_expired?
        @access_token
      elsif @access_token && token_expired?
        refresh_access_token
      else
        get_access_token
      end
    end

    def refresh_access_token
      result = Saasu::Client.connection.post('authorisation/refresh') do |request|
        request.body = { grant_type: 'refresh_token', refresh_token: @refresh_token }.to_json
      end

      unless result.status == 200
        raise "Failed to authenicate Saasu API. Please check your username and password."
      end

      @access_token = result.body['access_token']
      @token_expiry = DateTime.now + (result.body['expires_in']).to_i.seconds

      @access_token
    end

    def get_access_token
      result = Saasu::Client.connection.post('authorisation/token') do |request|
        request.body = { grant_type: 'password', scope: 'full', username: Saasu::Config.username, password: Saasu::Config.password }.to_json
      end

      unless result.status == 200
        raise "Failed to authenicate Saasu API. Please check your username and password."
      end

      @access_token = result.body['access_token']
      @refresh_token = result.body['refresh_token']
      @token_expiry = DateTime.now + (result.body['expires_in']).to_i.seconds

      @access_token
    end
  end
end
