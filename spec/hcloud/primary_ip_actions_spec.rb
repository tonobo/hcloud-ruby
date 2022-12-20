# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::PrimaryIP, doubles: :primary_ip do
  include_context 'test doubles'
  include_context 'action tests'

  let :primary_ips do
    Array.new(Faker::Number.within(range: 20..150)).map { new_primary_ip }
  end

  let(:primary_ip) { primary_ips.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :primary_ip_obj do
    stub_item(:primary_ips, primary_ip)
    client.primary_ips[primary_ip[:id]]
  end

  context '#assign' do
    it 'handles missing assigne_id' do
      expect do
        primary_ip_obj.assign(assignee_id: nil, assignee_type: 'server')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'defaults to assignee_type "server"' do
      stub = stub_action(:primary_ips, primary_ip[:id], :assign) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'assignee_type' => 'server' }))

        {
          action: build_action_resp(
            :assign_primary_ip, :success,
            resources: [
              { id: 42, type: 'server' },
              { id: primary_ip[:id], type: 'primary_ip' }
            ]
          )
        }
      end

      primary_ip_obj.assign(assignee_id: 42)
      expect(stub.times_called).to eq(1)
    end

    it 'works' do
      test_action(
        :assign,
        :assign_primary_ip,
        params: { assignee_id: 42 },
        additional_resources: %i[server]
      )
    end
  end

  context '#unassign' do
    it 'works' do
      test_action(:unassign, :unassign_primary_ip, additional_resources: %i[server])
    end
  end

  context '#change_dns_ptr' do
    it 'handles missing ip' do
      expect { primary_ip_obj.change_dns_ptr(ip: nil, dns_ptr: 'example.com') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'allows dns_ptr nil' do
      test_action(:change_dns_ptr, params: { ip: '2001:db8::10', dns_ptr: nil })
    end

    it 'works with IPv4' do
      test_action(:change_dns_ptr, params: { ip: '192.0.2.0', dns_ptr: 'example.com' })
    end

    it 'works with IPv6' do
      test_action(:change_dns_ptr, params: { ip: '2001:db8::10', dns_ptr: 'example.com' })
    end
  end

  context '#change_protection' do
    it 'works' do
      test_action(:change_protection, params: { delete: true }, additional_resources: %i[server])
    end
  end
end
