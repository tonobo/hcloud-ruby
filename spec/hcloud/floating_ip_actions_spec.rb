# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::FloatingIP, doubles: :floating_ip do
  include_context 'test doubles'
  include_context 'action tests'

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
      test_action(
        :assign,
        :assign_floating_ip,
        params: { server: 42 },
        additional_resources: %i[server]
      )
    end
  end

  context '#unassign' do
    it 'works' do
      test_action(
        :unassign,
        :unassign_floating_ip,
        additional_resources: %i[server]
      )
    end
  end

  context '#change_dns_ptr' do
    it 'handles missing ip' do
      expect { floating_ip_obj.change_dns_ptr(ip: nil, dns_ptr: 'example.com') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'works' do
      test_action(:change_dns_ptr, params: { ip: '2001:db8::1', dns_ptr: 'example.com' })
    end
  end
end
