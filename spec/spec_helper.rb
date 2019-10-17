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
end
