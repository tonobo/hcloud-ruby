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

  %w[actions servers placement_groups].each do |kind|
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

  def fetch_uri_params(request)
    URI.parse(request.url).query.split('&').map { |pair| pair.split('=') }.to_h
  end

  def page_info(request)
    opts = fetch_uri_params(request)
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

  def stub_create(resource_name, params)
    stub("#{resource_name}s") do |req, _info|
      expect(req.options[:method]).to eq(:post)
      body = Oj.load(req.encoded_body)
      params.each do |field, val|
        expect(body[field.to_s]).to eq val
      end

      {
        body: { resource_name => send("new_#{resource_name}", params) },
        code: 201
      }
    end
  end

  def stub_update(resource_name, params)
    res_id = params.delete(:id)
    stub([resource_name, res_id].join('/')) do |req, _info|
      p req
      expect(req.options[:method]).to eq(:put)

      res = client.send(resource_name).find(res_id)
      params.each do |name, val|
        res[name] = val
      end

      {
        body: { resource_name => res },
        code: 200
      }
    end
  end

  def stub_delete(resource_name, res_id)
    stub([resource_name, res_id].join('/')) do |req, _info|
      p req
      expect(req.options[:method]).to eq(:post)
      {
        body: { resource_name => client.send(resource_name).find(res_id) },
        code: 200
      }
    end
  end

  def stub_collection(key, collection, resource_name: nil)
    # Stub resource not found for ID=0
    stub([resource_name || key, 0].join('/')) do
      { body: { error: { code: :not_found } }, code: 404 }
    end

    # Stub all individual resources first
    collection.each do |obj|
      stub([[resource_name || key], obj[:id]].join('/')) do |_request, _page|
        {
          body: {
            (resource_name || key).to_s.gsub(/s$/, '') => obj
          },
          code: 200
        }
      end
    end

    stub(key) do |request, page_info|
      yield(request, page_info) if block_given?

      opts = fetch_uri_params(request)
      opts.delete('page')
      opts.delete('per_page')

      if opts.any?
        collection = collection.select do |obj|
          opts.map do |field, val|
            obj[field.to_sym] == val
          end.inject { _1 && _2 }
        end
      end
      {
        body: {
          (resource_name || key) => collection[page_info.delete(:requested_range)].to_a
        }.merge(pagination(collection, **page_info)),
        code: 200
      }
    end
  end
end
