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

RSpec.configure do |c|
  Faker::Config.random = Random.new(c.seed)
end
