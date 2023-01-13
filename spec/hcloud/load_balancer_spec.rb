# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'
require 'support/it_supports_metrics'

describe Hcloud::LoadBalancer, doubles: :load_balancer do
  let :load_balancers do
    Array.new(Faker::Number.within(range: 10..50)).map { new_load_balancer }
  end

  let(:load_balancer) { load_balancers.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_metrics', described_class, \
                   %i[open_connections connections_per_second requests_per_second
                      bandwidth]

  context '#create' do
    let :required_params do
      {
        name: 'test-lb',
        load_balancer_type: 'lb11',
        algorithm: { type: 'round_robin' },
        location: 'fsn1'
      }
    end

    it 'handles missing name' do
      required_params[:name] = nil
      expect { client.load_balancers.create(**required_params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles missing type' do
      required_params[:load_balancer_type] = nil
      expect { client.load_balancers.create(**required_params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles missing algorithm' do
      required_params[:algorithm] = nil
      expect do
        client.load_balancers.create(**required_params)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'handles blank algoritm' do
      required_params[:algorithm] = { type: '' }
      expect do
        client.load_balancers.create(**required_params)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'handles missing network_zone and location' do
      required_params[:location] = nil
      required_params[:network_zone] = nil
      expect do
        client.load_balancers.create(**required_params)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    context 'works' do
      it 'with required parameters' do
        response_params = {
          name: required_params[:name],
          load_balancer_type: new_load_balancer_type,
          algorithm: required_params[:algorithm],
          location: new_location
        }
        expectation = stub_create(
          :load_balancer, required_params, response_params: response_params
        )

        _action, lb = client.load_balancers.create(**required_params)
        expect(expectation.times_called).to eq(1)

        expect(lb).to be_a Hcloud::LoadBalancer
        expect(lb.id).to be_a Integer
        expect(lb.created).to be_a Time
        expect(lb.name).to eq('test-lb')
        expect(lb.load_balancer_type).to be_a Hcloud::LoadBalancerType
        expect(lb.algorithm).to eq({ 'type' => 'round_robin' })
        expect(lb.location).to be_a Hcloud::Location
      end

      it 'with all parameters' do
        params = required_params.dup
        params[:network] = 42
        params[:public_interface] = true
        params[:services] = {
          listen_port: 80,
          destination_port: 80,
          protocol: 'tcp',
          proxyprotocol: true,
          health_check: {
            interval: 60,
            port: 80,
            protocol: 'tcp',
            retries: 3,
            timeout: 10
          }
        }
        params[:targets] = {
          type: 'server',
          server: { id: 42 },
          health_status: {
            listen_port: 80,
            status: 'healthy'
          }
        }
        params[:labels] = { 'key' => 'value', 'novalue' => '' }

        response_params = {
          name: params[:name],
          load_balancer_type: new_load_balancer_type,
          algorithm: params[:algorithm],
          location: new_location,
          services: params[:services],
          targets: params[:targets],
          labels: params[:labels]
        }

        expectation = stub_create(:load_balancer, params, response_params: response_params)

        _action, lb = client.load_balancers.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(lb).to be_a described_class
        expect(lb.id).to be_a Integer
        expect(lb.name).to eq('test-lb')
        expect(lb.load_balancer_type).to be_a Hcloud::LoadBalancerType
        expect(lb.algorithm).to eq({ 'type' => 'round_robin' })
        expect(lb.location).to be_a Hcloud::Location
        expect(lb.created).to be_a Time
        expect(lb.services).to eq(params[:services].deep_stringify_keys)
        expect(lb.labels).to eq(params[:labels].deep_stringify_keys)
      end
    end

    it 'validates uniq name' do
      stub_error(:load_balancers, :post, 'uniqueness_error', 409)

      expect do
        client.load_balancers.create(**required_params)
      end.to raise_error(Hcloud::Error::UniquenessError)
    end
  end
end
