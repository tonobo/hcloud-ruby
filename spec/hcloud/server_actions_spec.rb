# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Server, doubles: :server do
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

  def test_parameterless_action(action_name, command_name)
    expectation = stub_action(:servers, server[:id], action_name) do |_req, _info|
      {
        action: build_action_resp(
          command_name, :running,
          resources: [{ id: server[:id], type: 'server' }]
        )
      }
    end

    action = server_obj.send(action_name)
    expect(expectation.times_called).to eq(1)

    expect(action).to be_a(Hcloud::Action)
    expect(action.command).to eq(command_name.to_s)
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
      expectation = stub_action(:servers, server[:id], :change_type) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'server_type' => 'cx11', 'upgrade_disk' => true })
        )

        {
          action: build_action_resp(
            :change_server_type, :running,
            resources: [{ id: server[:id], type: 'server' }]
          )
        }
      end

      action = server_obj.change_type(server_type: 'cx11', upgrade_disk: true)
      expect(expectation.times_called).to eq(1)

      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('change_server_type')
    end
  end

  context '#attach_iso' do
    it 'handles missing iso' do
      expect do
        server_obj.attach_iso(iso: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:servers, server[:id], :attach_iso) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'iso' => 'FreeBSD-11.0-RELEASE-amd64-dvd1' })
        )

        {
          action: build_action_resp(
            :attach_iso, :running,
            resources: [{ id: server[:id], type: 'server' }]
          )
        }
      end

      action = server_obj.attach_iso(iso: 'FreeBSD-11.0-RELEASE-amd64-dvd1')
      expect(expectation.times_called).to eq(1)

      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('attach_iso')
    end
  end

  context '#attach_to_network' do
    it 'handles missing network' do
      expect do
        server_obj.attach_to_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:servers, server[:id], :attach_to_network) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'network' => 1, 'ip' => '10.0.0.10' })
        )

        {
          action: build_action_resp(
            :attach_to_network, :running,
            resources: [{ id: server[:id], type: 'server' }, { id: 1, type: 'network' }]
          )
        }
      end

      action = server_obj.attach_to_network(network: 1, ip: '10.0.0.10')
      expect(expectation.times_called).to eq(1)

      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('attach_to_network')
    end
  end

  context '#detach_from_network' do
    it 'handles missing network' do
      expect do
        server_obj.detach_from_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      expectation = stub_action(:servers, server[:id], :detach_from_network) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including({ 'network' => 1 })
        )

        {
          action: build_action_resp(
            :detach_from_network, :running,
            resources: [{ id: server[:id], type: 'server' }, { id: 1, type: 'network' }]
          )
        }
      end

      action = server_obj.detach_from_network(network: 1)
      expect(expectation.times_called).to eq(1)

      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('detach_from_network')
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
    test_parameterless_action(:enable_backup, :enable_backup)
  end

  it '#disable_backup' do
    test_parameterless_action(:disable_backup, :disable_backup)
  end

  it '#poweron' do
    test_parameterless_action(:poweron, :start_server)
  end

  it '#poweroff' do
    test_parameterless_action(:poweroff, :stop_server)
  end

  it '#shutdown' do
    test_parameterless_action(:shutdown, :shutdown_server)
  end

  it '#reboot' do
    test_parameterless_action(:reboot, :reboot_server)
  end

  it '#reset' do
    test_parameterless_action(:reset, :reset_server)
  end

  it '#disable_rescue' do
    test_parameterless_action(:disable_rescue, :disable_rescue)
  end

  it '#detach_iso' do
    test_parameterless_action(:detach_iso, :detach_iso)
  end
end
