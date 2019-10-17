# frozen_string_literal: true

require 'faker'
require 'active_support/all'

RSpec.shared_context 'test doubles' do
  before(:each) do
    Hcloud::Client.connection =
      Hcloud::Client.new(token: 'secure', auto_pagination: true)
    Typhoeus::Config.block_connection = true
    Typhoeus::Expectation.clear
  end

  let :client do
    Hcloud::Client.new(token: 'secure', auto_pagination: true)
  end

  after(:each) do
    Typhoeus::Config.block_connection = false
    Hcloud::Client.connection = nil
  end

  %w[actions servers].each do |kind|
    require_relative "./#{kind}"
    include_context "#{kind} doubles"
  end

  def random_choice(*args)
    args[Faker::Number.within(range: 0..args.size - 1)]
  end

  def pagination(collection, **kwargs)
    {
      meta: {
        pagination: {
          page: 1,
          per_page: collection.size,
          total_entries: collection.size,
          next_page: 1,
          previous_page: 1,
          last_page: 1
        }.merge(kwargs)
      }
    }
  end

  def page_info(request)
    opts = URI.parse(request.url)
              .query
              .split('&')
              .map { |pair| pair.split('=') }
              .to_h
    info = {
      page: opts['page']&.to_i || 1,
      per_page: opts['per_page']&.to_i || 25
    }
    starting_point = (info[:page] - 1) * info[:per_page]
    info[:requested_range] = starting_point...(starting_point + info[:per_page])
    info
  end

  def non_sym(value)
    return value.to_s if value.is_a? Symbol
    return value.deep_stringify_keys if value.is_a? Hash

    value
  end

  def stub(path)
    Typhoeus.stub(%r{https://api.hetzner.cloud/v1/#{path}}) do |request|
      args = yield(request, page_info(request))
      args[:body] = Oj.dump(args[:body], mode: :compat) if args.key?(:body)
      Typhoeus::Response.new(args)
    end
  end

  def stub_collection(key, collection)
    stub(key) do |request, page_info|
      yield(request, page_info) if block_given?
      {
        body: {
          key => collection[page_info.delete(:requested_range)]
        }.merge(pagination(collection, **page_info)),
        code: 200
      }
    end
  end
end
