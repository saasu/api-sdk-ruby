require 'faraday'
require 'faraday_middleware'

module Saasu
  class Client
    class_attribute :connection

    class << self
      def request(method, url, params = {})
        Saasu::Auth.authenticate
        request_url = url + "?FileId=#{Saasu::Config.file_id}"
        response = connection.send(method, request_url, params)

        if response.status == 200
          response.body
        elsif response.status == 404
          raise ResourceNotFoundError.new()
        else
          raise InvalidResponseError.new(response.status, response.reason_phrase, response.body)
        end
      end

      def connection
        @@connection ||= initialize_connection
      end

      private
      def initialize_connection
        con = Faraday.new(url: api_url) do |c|
          c.request :json

          c.response :json, :content_type => /\bjson$/

          c.use :instrumentation
          c.adapter  Faraday.default_adapter
        end

        con.headers['X-Api-Version'] = '1.0'
        con
      end

      def api_url
        Saasu::Config.api_url || 'https://api.saasu.com/'
      end
    end
  end
  
  class ResourceNotFoundError < StandardError
    def initialize(msg="Resource not found.")
      super
    end
  end
  
  class InvalidResponseError < StandardError
    attr_reader :status, :reason, :body
    def initialize(status="",reason="",body="")
      @status = status
      @reason = reason
      @body = body
      super("Server did not return a valid response. Response status: #{status}. Reason phrase: #{reason}. Response body: #{body}")
    end
  end
  
end
