require 'webmock'
require 'webmock/rspec'

require 'bundler/setup'
Bundler.setup

require 'active_support'
require 'active_support/core_ext'
require 'saasu'
# require './spec/support/test_definition.rb'

Bundler.require(:default, :development)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.color = :enabled
  config.order = :random
end

Dir[File.dirname(__FILE__) + '*.rb'].each { |file| require_relative file }
