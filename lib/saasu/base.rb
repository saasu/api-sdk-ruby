module Saasu
  class Base
    attr_reader :attributes

    def initialize(params = {})
      @attributes = params.deep_stringify_keys
    end

    def self.all
      validate_method_is_implemented_in_saasu_api(:index)

      Saasu::Client.request(:get, resource_url.pluralize).values.first.map do |record|
        self.new(record)
      end
    end

    def self.find(id)
      validate_method_is_implemented_in_saasu_api(:show)

      response = Saasu::Client.request(:get, resource_url(id))

      if response.present?
        self.new(response)
      else
        response.body
      end
    end

    def self.where(params)
      validate_method_is_implemented_in_saasu_api(:index)
      validate_filters(params)

      Saasu::Client.request(:get, resource_url.pluralize, params).values.first.map do |record|
        self.new(record)
      end
    end

    def delete
      validate_method_is_implemented_in_saasu_api(:destroy)

      if Saasu::Client.request(:delete, self.class.resource_url(id))["StatusMessage"] == "Ok"
        self['Id'] = nil
        true
      else
        false
      end
    end

    def self.delete(id)
      validate_method_is_implemented_in_saasu_api(:destroy)

      Saasu::Client.request(:delete, resource_url(id))
    end

    def save
      if self.id.present?
        validate_method_is_implemented_in_saasu_api(:update)
        Saasu::Client.request(:put, self.class.resource_url(id), @attributes)
      else
        validate_method_is_implemented_in_saasu_api(:create)
        self['Id'] = Saasu::Client.request(:post, self.class.resource_url, @attributes).values.first
      end

      @attributes = Saasu::Client.request(:get, self.class.resource_url(id))
      true
    end

    def update(params)
      validate_method_is_implemented_in_saasu_api(:update)

      params.each do |key, value|
        self[key] = value
      end

      save
    end

    def self.create(params)
      validate_method_is_implemented_in_saasu_api(:create)

      id = Saasu::Client.request(:post, resource_url, params).values.first
      new(Saasu::Client.request(:get, resource_url(id)))
    end

    def validate_method_is_implemented_in_saasu_api(method_name)
      self.class.validate_method_is_implemented_in_saasu_api(method_name)
    end

    def self.validate_method_is_implemented_in_saasu_api(method_name)
      raise "This method is not currently supported by Saasu API" unless @api_methods.include?(method_name)
    end

    def [](key)
      @attributes[key.to_s]
    end

    def []=(key, value)
      @attributes[key.to_s] = value
    end

    def method_missing meth, *args, &cb
      if meth.in?(getter_methods)
        @attributes[meth.to_s.classify]
      elsif meth.in?(setter_methods)
        @attributes[meth.to_s.gsub('=','').classify] = args.flatten.compact.first
      else
        super meth, *args, &cb
      end
    end

    def to_s
      "#{self.class.name.demodulize} ##{self.id}"
    end

    def id
      @attributes.has_key?('Id') ? @attributes['Id'] : @attributes['TransactionId']
    end

    protected
    def getter_methods
      @attributes.keys.map { |k| k.underscore.to_sym }
    end

    def setter_methods
      @attributes.keys.map { |k| "#{k.underscore}=".to_sym }
    end

    def self.allowed_methods(*params)
      @api_methods = params
    end

    def self.filter_by(params)
      @filters = params
    end

    def self.resource_url(id = nil)
      [name.demodulize.downcase, id].compact.join('/')
    end

    def self.validate_filters(params)
      params.keys.each do |key|
        raise "Filter not supported by Saasu API: #{key}. Supported filters: #{@filters.join(", ")}" unless key.to_s.in?(@filters)
      end
    end
  end
end
