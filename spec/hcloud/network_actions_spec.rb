# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Network, doubles: :network do
  let :networks do
    Array.new(Faker::Number.within(range: 20..150)).map { new_network }
  end

  let(:network) { networks.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :network_obj do
    stub_item(:networks, network)
    client.networks[network[:id]]
  end

  # TODO: Also this spec could profit from a standardization mechanism for action tests like
  #       server and load balancer
  context '#add_route' do
    it 'handles missing destination' do
      expect do
        network_obj.add_route(destination: nil, gateway: '192.168.2.2')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing gateway' do
      expect do
        network_obj.add_route(destination: '192.168.0.0/24', gateway: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:networks, network[:id], :add_route) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including(
            { 'destination' => '192.168.0.0/24', 'gateway' => '192.168.2.2' }
          )
        )

        {
          action: build_action_resp(
            :add_route, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.add_route(destination: '192.168.0.0/24', gateway: '192.168.2.2')
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(network[:id])
    end
  end

  context '#delete_route' do
    it 'handles missing destination' do
      expect do
        network_obj.del_route(destination: nil, gateway: '192.168.2.2')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing gateway' do
      expect do
        network_obj.del_route(destination: '192.168.0.0/24', gateway: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:networks, network[:id], :delete_route) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including(
            { 'destination' => '192.168.0.0/24', 'gateway' => '192.168.2.2' }
          )
        )

        {
          action: build_action_resp(
            :delete_route, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.del_route(destination: '192.168.0.0/24', gateway: '192.168.2.2')
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(network[:id])
    end
  end

  context '#add_subnet' do
    it 'handles missing type' do
      expect do
        network_obj.add_subnet(
          ip_range: '10.0.0.0/24', network_zone: 'eu-central', type: nil
        )
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing network_zone' do
      expect do
        network_obj.add_subnet(
          ip_range: '10.0.0.0/24', network_zone: nil, type: 'cloud'
        )
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:networks, network[:id], :add_subnet) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including(
            { 'ip_range' => '10.0.0.0/24', 'network_zone' => 'eu-central', 'type' => 'cloud' }
          )
        )

        {
          action: build_action_resp(
            :add_subnet, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.add_subnet(
        ip_range: '10.0.0.0/24', network_zone: 'eu-central', type: 'cloud'
      )
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(network[:id])
    end
  end

  context '#delete_subnet' do
    it 'handles missing ip_range' do
      expect do
        network_obj.del_subnet(ip_range: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:networks, network[:id], :delete_subnet) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'ip_range' => '10.0.0.0/24' }))

        {
          action: build_action_resp(
            :delete_subnet, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.del_subnet(ip_range: '10.0.0.0/24')
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(network[:id])
    end
  end

  context '#change_ip_range' do
    it 'handles missing ip_range' do
      expect do
        network_obj.change_ip_range(ip_range: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:networks, network[:id], :change_ip_range) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'ip_range' => '10.0.0.0/24' }))

        {
          action: build_action_resp(
            :change_ip_range, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.change_ip_range(ip_range: '10.0.0.0/24')
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(network[:id])
    end
  end

  context '#change_protection' do
    it 'works' do
      expectation = stub_action(:networks, network[:id], :change_protection) do |_req, _info|
        {
          action: build_action_resp(
            :change_protection, :running,
            resources: [{ id: network[:id], type: 'network' }]
          )
        }
      end

      action = network_obj.change_protection
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
    end
  end
end
