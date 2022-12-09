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

  %w[actions datacenters firewalls isos servers ssh_keys placement_groups].each do |kind|
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

  def stub(path, method = nil)
    options = method.nil? ? {} : { method: method }

    Typhoeus.stub(%r{^https://api\.hetzner\.cloud/v1/#{path}}, options) do |request|
      args = yield(request, page_info(request))
      args[:body] = Oj.dump(args[:body], mode: :compat) if args.key?(:body)
      Typhoeus::Response.new(args)
    end
  end

  def stub_create(resource_name, params, response_params: nil, action: nil, actions: nil)
    stub("#{resource_name}s", :post) do |req, _info|
      expect(req.options[:method]).to eq(:post)
      expect(req).to have_body_params(a_hash_including(params.deep_stringify_keys))

      resp = {
        # most resources have the same response and query params (e.g. "name"),
        # but some parameters have a different name on requests ("apply_to") compared
        # to the response ("applied_to")
        body: { resource_name => send("new_#{resource_name}", (response_params || params)) },
        code: 201
      }

      resp[:action] = action unless action.nil?
      resp[:actions] = actions unless actions.nil?

      resp
    end
  end

  def stub_update(resource_name, resource_data, params)
    stub(["#{resource_name}s", resource_data[:id]].join('/'), :put) do |req, _info|
      expect(req.options[:method]).to eq(:put)
      expect(req).to have_body_params(a_hash_including(params.deep_stringify_keys))

      res = resource_data.dup
      params.each do |name, val|
        res[name] = val
      end

      {
        body: { resource_name => res },
        code: 200
      }
    end
  end

  def stub_delete(resource_name, resource_data)
    stub(["#{resource_name}s", resource_data[:id]].join('/'), :delete) do |req, _info|
      # TODO: 200 + resource data is only true for some API endpoints,
      #       some also respond with 204 and no data
      expect(req.options[:method]).to eq(:delete)

      {
        body: { resource_name => resource_data },
        code: 200
      }
    end
  end

  def stub_item(resource_name, item)
    stub([resource_name, item[:id]].join('/')) do |_request, _page|
      {
        body: {
          resource_name.to_s.gsub(/s$/, '') => item
        },
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
      stub_item((resource_name || key), obj)
    end

    stub(key) do |request, page_info|
      yield(request, page_info) if block_given?

      opts = fetch_uri_params(request)
      opts.delete('page')
      opts.delete('per_page')

      if opts.any?
        collection = collection.select do |obj|
          opts.map do |field, val|
            obj[field.to_sym].to_s == val.to_s
          end.all?
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

  def stub_error(resource, method, error_code, http_code)
    stub(resource, method) do |_req, _info|
      {
        body: { error: { message: '', code: error_code, details: nil } },
        code: http_code
      }
    end
  end
end
