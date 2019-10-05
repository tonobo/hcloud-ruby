# frozen_string_literal: true

require 'grape'
require 'active_support/all'

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require_relative './fake_service/base'

require 'rspec'
require 'webmock/rspec'
require 'hcloud'

RSpec.configure do |c|
  c.before(:each) do
    stub_request(:any, /api.hetzner.cloud/).to_rack(Hcloud::FakeService::Base)
  end
end
