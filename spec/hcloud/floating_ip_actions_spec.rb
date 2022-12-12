# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::FloatingIP, doubles: :floating_ip do
  include_context 'test doubles'

  let :floating_ips do
    Array.new(Faker::Number.within(range: 20..150)).map { new_floating_ip }
  end

  let(:floating_ip) { floating_ips.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :floating_ip_obj do
    stub_item(:floating_ips, floating_ip)
    client.floating_ips[floating_ip[:id]]
  end

  context '#assign' do
    it 'handles missing server ID' do
      expect do
        floating_ip_obj.assign(server: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:floating_ips, floating_ip[:id], :assign) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'server' => 42 }))

        {
          action: build_action_resp(
            :assign_floating_ip, :success,
            resources: [
              { id: 42, type: 'server' },
              { id: floating_ip[:id], type: 'floating_ip' }
            ]
          )
        }
      end

      action = floating_ip_obj.assign(server: 42)
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources.map { |res| res['id'] }).to eq([42, floating_ip[:id]])
    end
  end

  context '#unassign' do
    it 'works' do
      expectation = stub_action(:floating_ips, floating_ip[:id], :unassign) do |_req, _info|
        {
          action: build_action_resp(
            :unassign_floating_ip, :success,
            resources: [
              { id: 42, type: 'server' },
              { id: floating_ip[:id], type: 'floating_ip' }
            ]
          )
        }
      end

      action = floating_ip_obj.unassign
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources.map { |res| res['id'] }).to eq([42, floating_ip[:id]])
    end
  end

  context '#change_dns_ptr' do
    it 'handles missing ip' do
      expect { floating_ip_obj.change_dns_ptr(ip: nil, dns_ptr: 'example.com') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'works' do
      expectation = stub_action(:floating_ips, floating_ip[:id], :change_dns_ptr) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including(
            { 'ip' => '2001:db8::1', 'dns_ptr' => 'example.com' }
          )
        )

        {
          action: build_action_resp(
            :change_dns_ptr, :success,
            resources: [
              { id: floating_ip[:id], type: 'floating_ip' }
            ]
          )
        }
      end

      action = floating_ip_obj.change_dns_ptr(ip: '2001:db8::1', dns_ptr: 'example.com')
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('change_dns_ptr')
      expect(action.resources[0]['id']).to eq(floating_ip[:id])
    end
  end
end
