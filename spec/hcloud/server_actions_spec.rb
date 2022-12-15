# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Server, doubles: :server do
  include_context 'test doubles'
  include_context 'action tests'

  let :servers do
    Array.new(Faker::Number.within(range: 20..150)).map { new_server }
  end

  let(:server) { servers.sample }

  let :server_obj do
    stub_item(:servers, server)
    client.servers[server[:id]]
  end

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  context '#enable_rescue' do
    it 'works' do
      expectation = stub_action(:servers, server[:id], :enable_rescue) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'ssh_keys' => [42, 43], 'type' => 'linux64' })
        )

        {
          action: build_action_resp(
            :enable_rescue, :running,
            resources: [{ id: server[:id], type: 'server' }]
          ),
          root_password: 'test123'
        }
      end

      action, pass = server_obj.enable_rescue(type: 'linux64', ssh_keys: [42, 43])
      expect(expectation.times_called).to eq(1)
      expect(pass).to eq('test123')
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('enable_rescue')
    end
  end

  context '#reset_password' do
    it 'works' do
      expectation = stub_action(:servers, server[:id], :reset_password) do |_req, _info|
        {
          action: build_action_resp(
            :reset_password, :running,
            resources: [{ id: server[:id], type: 'server' }]
          ),
          root_password: 'test123'
        }
      end

      action, pass = server_obj.reset_password
      expect(expectation.times_called).to eq(1)
      expect(pass).to eq('test123')
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('reset_password')
    end
  end

  context '#create_image' do
    it 'works' do
      expectation = stub_action(:servers, server[:id], :create_image) do |req, _info|
        params = { type: 'snapshot', description: 'test' }
        expect(req).to have_body_params(a_hash_including(params.stringify_keys))

        {
          action: build_action_resp(
            :create_image, :running,
            resources: [{ id: server[:id], type: 'server' }]
          ),
          image: new_image(params)
        }
      end

      action, image = server_obj.create_image(type: 'snapshot', description: 'test')
      expect(expectation.times_called).to eq(1)

      expect(image).to be_a Hcloud::Image
      expect(image.type).to eq('snapshot')
      expect(image.description).to eq('test')
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('create_image')
    end
  end

  context '#create_image' do
    it 'handles missing image' do
      expect do
        server_obj.rebuild(image: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:servers, server[:id], :rebuild) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'image' => 'source-image' })
        )

        {
          action: build_action_resp(
            :rebuild_server, :running,
            resources: [{ id: server[:id], type: 'server' }]
          ),
          root_password: 'test123'
        }
      end

      action, password = server_obj.rebuild(image: 'source-image')
      expect(expectation.times_called).to eq(1)

      expect(password).to eq('test123')
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('rebuild_server')
    end
  end

  context '#change_type' do
    it 'handles missing server_type' do
      expect do
        server_obj.change_type(server_type: nil, upgrade_disk: false)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing upgrade_disk' do
      expect do
        server_obj.change_type(server_type: 'cx11', upgrade_disk: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(
        :change_type, :change_server_type,
        params: { server_type: 'cx11', upgrade_disk: true }
      )
    end
  end

  context '#attach_iso' do
    it 'handles missing iso' do
      expect do
        server_obj.attach_iso(iso: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:attach_iso, params: { iso: 'FreeBSD-11.0-RELEASE-amd64-dvd1' })
    end
  end

  context '#attach_to_network' do
    it 'handles missing network' do
      expect do
        server_obj.attach_to_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:attach_to_network, params: { network: 1, ip: '10.0.0.10' })
    end
  end

  context '#detach_from_network' do
    it 'handles missing network' do
      expect do
        server_obj.detach_from_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:detach_from_network, params: { network: 1 })
    end
  end

  context '#add_to_placement_group' do
    it 'handles missing placement_group' do
      expect do
        server_obj.add_to_placement_group(placement_group: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:add_to_placement_group, params: { placement_group: 42 })
    end
  end

  context '#remove_from_placement_group' do
    it 'works' do
      test_action(:remove_from_placement_group)
    end
  end

  context '#change_alias_ips' do
    it 'handles missing alias_ips' do
      expect do
        server_obj.change_alias_ips(alias_ips: nil, network: 42)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing network' do
      expect do
        server_obj.change_alias_ips(alias_ips: ['10.0.10.2'], network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:change_alias_ips, params: { alias_ips: ['10.0.10.2'], network: 42 })
    end
  end

  context '#change_dns_ptr' do
    it 'handles missing dns_ptr' do
      expect do
        server_obj.change_dns_ptr(ip: '192.0.2.0', dns_ptr: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing ip' do
      expect do
        server_obj.change_dns_ptr(ip: nil, dns_ptr: 'example.com')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:change_dns_ptr, params: { ip: '192.0.2.0', dns_ptr: 'example.com' })
    end
  end

  context '#request_console' do
    it 'works' do
      expectation = stub_action(:servers, server[:id], :request_console) do |_req, _info|
        {
          action: build_action_resp(
            :request_console, :running,
            resources: [{ id: server[:id], type: 'server' }]
          ),
          password: 'test123',
          wss_url: 'wss://console.hetzner.cloud/?server_id=1&token=secret'
        }
      end

      action, wss_url, password = server_obj.request_console
      expect(expectation.times_called).to eq(1)

      expect(password).to eq('test123')
      expect(wss_url).to eq('wss://console.hetzner.cloud/?server_id=1&token=secret')

      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('request_console')
    end
  end

  it '#enable_backup' do
    test_action(:enable_backup)
  end

  it '#disable_backup' do
    test_action(:disable_backup)
  end

  it '#poweron' do
    test_action(:poweron, :start_server)
  end

  it '#poweroff' do
    test_action(:poweroff, :stop_server)
  end

  it '#shutdown' do
    test_action(:shutdown, :shutdown_server)
  end

  it '#reboot' do
    test_action(:reboot, :reboot_server)
  end

  it '#reset' do
    test_action(:reset, :reset_server)
  end

  it '#disable_rescue' do
    test_action(:disable_rescue)
  end

  it '#detach_iso' do
    test_action(:detach_iso)
  end
end
