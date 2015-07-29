module Saasu
  class Base
    def initialize(params = {})
      @attributes = params
    end

    def self.all
      validate_method_is_implemented_in_saasu_api(:index)

      Saasu::Client.request(:get, resource_url.pluralize)
    end

    def find(id)
      validate_method_is_implemented_in_saasu_api(:show)
      
      Saasu::Client.request(:get, resource_url(id)).first
    end

    def self.where(params)
      validate_method_is_implemented_in_saasu_api(:index)
      validate_filters(params)

      Saasu::Client.request(:get, resource_url.pluralize, params).first
    end

    def delete
      validate_method_is_implemented_in_saasu_api(:destroy)

      Saasu::Client.request(:delete, resource_url(id))
    end

    def save
      validate_method_is_implemented_in_saasu_api(:create)
      validate_method_is_implemented_in_saasu_api(:update)

      if self.id.persisted?
        Saasu::Client.request(:put, resource_url(self.id))
      else
        Saasu::Client.request(:post, resource_url.pluralize)
      end
    end

    def self.create(params)
      validate_method_is_implemented_in_saasu_api(:create)

      Saasu::Client.request(:post, resource_url, params)
    end

    def update(params)
      validate_method_is_implemented_in_saasu_api(:update)

      Saasu::Client.request(:put, resource_url)
    end

    def validate_method_is_implemented_in_saasu_api(method_name)
      self.class.validate_method_is_implemented_in_saasu_api(method_name)
    end

    def self.validate_method_is_implemented_in_saasu_api(method_name)
      raise "This method is not currently supported by Saasu API" unless @api_methods.include?(method_name)
    end

    protected
    def self.allowed_methods(*params)
      @api_methods = params
    end

    def self.filter_by(params)
      @filters = params
    end

    def self.resource_url(id = nil)
      name.demodulize.downcase
    end

    def self.validate_filters(params)
      params.keys.each do |key|
        raise "Filter not supported by Saasu API: #{key}. Supported filters: #{@filters.join(",")}" unless key.to_s.in?(@filters)
      end
    end
  end
end
