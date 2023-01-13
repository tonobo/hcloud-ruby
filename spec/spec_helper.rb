# frozen_string_literal: true

require 'grape'
require 'active_support/all'
require 'pry'

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require_relative './fake_service/base'
require_relative './doubles/base'
require_relative './doubles/action_tests'
require_relative './support/typhoeus_ext'
require_relative './support/matchers'

require 'rspec'
require 'hcloud'

def deep_load(scope)
  return unless scope.respond_to?(:constants)

  scope.constants.each do |const|
    next unless scope.autoload?(const)

    deep_load(scope.const_get(const))
  end
end

deep_load Hcloud

RSpec.configure do |c|
  Faker::Config.random = Random.new(c.seed)

  c.include_context 'test doubles', :doubles

  if ENV['LEGACY_TESTS']
    require 'webmock/rspec'
    c.before(:each) do
      stub_request(:any, /api.hetzner.cloud/).to_rack(Hcloud::FakeService::Base)
    end

    c.after(:all) do
      # Action holds the record of all executed actions (which can be queried
      # on the API). We need to delete this record after each example.
      Hcloud::FakeService::Action.reset
    end
  end
end
