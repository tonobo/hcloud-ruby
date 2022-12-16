# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'
require 'support/it_supports_metrics'
require 'support/it_supports_action_fetch'

RSpec.describe Hcloud::Server, doubles: :server do
  let :servers do
    Array.new(Faker::Number.within(range: 20..150)).map { new_server }
  end

  let(:server) { servers.sample }

  let :volumes do
    Array.new(Faker::Number.within(range: 2..10)).map { new_volume }
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector status]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_metrics', described_class, %i[cpu disk network]
  include_examples 'it_supports_action_fetch', described_class

  it 'fetch server' do
    stub_collection :servers, []
    expect(client.servers.count).to eq(0)
  end

  it 'has typed attributes' do
    stub_item(:servers, server)

    # Several resources need to be stubbed, because server only includes the "id"
    # and we create a future for that. When we try to access the future, we try to query its data
    # from the API.
    server[:public_net][:floating_ips].each do |floating_ip_id|
      stub_item(:floating_ips, new_floating_ip(id: floating_ip_id))
    end
    server[:public_net][:firewalls].map { |firewall| firewall[:id] }.each do |firewall_id|
      stub_item(:firewalls, new_firewall(id: firewall_id))
    end
    server[:load_balancers].each do |load_balancer_id|
      stub_item(:load_balancers, new_load_balancer(id: load_balancer_id))
    end
    stub_item(:primary_ips, new_primary_ip(**server[:public_net][:ipv4]))
    stub_item(:primary_ips, new_primary_ip(**server[:public_net][:ipv6]))

    obj = client.servers[server[:id]]

    expect(obj.created).to be_a Time
    expect(obj.datacenter).to be_a Hcloud::Datacenter
    expect(obj.image).to be_a Hcloud::Image unless obj.image.nil?
    expect(obj.iso).to be_a Hcloud::Iso unless obj.iso.nil?
    expect(obj.placement_group).to be_a Hcloud::PlacementGroup unless obj.placement_group.nil?
    expect(obj.server_type).to be_a Hcloud::ServerType
    expect(obj.volumes).to all be_a Hcloud::Volume

    # Floating IP is a future object which gets lazily loaded when required
    expect(obj.public_net[:floating_ips]).to all be_a Hcloud::Future
    expect(obj.public_net[:floating_ips].map(&:__getobj__)).to all be_a Hcloud::FloatingIP

    expect(obj.load_balancers).to all be_a Hcloud::Future
    expect(obj.load_balancers.map(&:__getobj__)).to all be_a Hcloud::LoadBalancer

    expect(obj.public_net[:ipv4]).to be_a Hcloud::Future
    expect(obj.public_net[:ipv4].__getobj__).to be_a Hcloud::PrimaryIP
    expect(obj.public_net[:ipv6]).to be_a Hcloud::Future
    expect(obj.public_net[:ipv6].__getobj__).to be_a Hcloud::PrimaryIP

    # TODO: "firewalls" has a bit an inconvenient structure for us, I guess we do NOT want to
    #       have the loaded Firewall under the "id" key?
    firewalls = obj.public_net[:firewalls].map { |firewall| firewall[:id] }
    expect(firewalls).to all be_a Hcloud::Future
    expect(firewalls.map(&:__getobj__)).to all be_a Hcloud::Firewall
  end

  it 'create new server, handle missing name' do
    expect { client.servers.create(server_type: 'cx11', image: 1) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid name' do
    stub('servers') do |request, _page_info|
      expect(request.options[:method]).to eq(:post)
      expect(Oj.load(request.options[:body], symbol_keys: true, mode: :compat)).to include(
        server_type: 'cx11',
        image: 1,
        name: 'moo_moo'
      )
      {
        body: {
          error: {
            code: :invalid_input,
            message: 'name is invalid'
          }
        },
        code: 400
      }
    end
    expect { client.servers.create(server_type: 'cx11', image: 1, name: 'moo_moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  context '#create' do
    it 'with required parameters' do
      related_action = new_action.merge(action_status(:running))
      stub_collection("servers/#{servers[0][:id]}/actions", [related_action], resource_name: :actions)
      stub('servers') do |_request, _page_info|
        {
          body: {
            server: servers[0],
            action: related_action,
            root_password: :moo,
            next_actions: [new_action(:running, command: 'start_server')]
          },
          code: 201
        }
      end
      action, server, pass, next_actions = nil
      expect do
        action, server, pass, next_actions = client.servers.create(
          name: 'moo', server_type: 'cx11', image: 1
        )
      end.not_to(raise_error)
      expect(action).to be_a Hcloud::Action
      expect(next_actions).to all be_a Hcloud::Action

      expect(server.actions.count).to eq(1)
      expect(server.id).to be_a Integer
      expect(server.rescue_enabled).to be servers[0][:rescue_enabled]
      expect(server.datacenter.id).to eq(servers[0].dig(:datacenter, :id))
      expect(server.created).to be_a Time
      expect(action.status).to eq('running')
      expect(pass).to eq('moo')
      expect(server.volumes).to be_a Array
      expect(server.private_net).to_not be_empty
    end

    def test_create_with_attribute(attribute, response_attribute)
      params = { name: 'moo', server_type: 'cx11', image: 1 }.merge(attribute)

      expectation = stub('servers', :post) do |request, _page_info|
        expect(request).to have_body_params(a_hash_including(attribute.deep_stringify_keys))

        {
          body: {
            # make sure that even though we create a new random server, the placement group
            # has the right ID in the response
            server: new_server(**response_attribute),
            action: new_action.merge(action_status(:running)),
            root_password: :moo
          },
          code: 201
        }
      end

      _action, server, _pass, _next_actions = client.servers.create(**params)
      expect(expectation.times_called).to eq(1)

      server
    end

    it 'with automount' do
      # automount only modifies the behaviour of volumes in this create request,
      # it is not a server attribute and thus is not contained in the returned server JSON
      test_create_with_attribute(
        { automount: true, volumes: [42] },
        { volumes: [new_volume({ id: 42 })] }
      )
    end

    it 'with firewalls' do
      server = test_create_with_attribute(
        { firewalls: [{ firewall: 42 }] },
        { public_net: { firewalls: [{ id: 42, status: 'applied' }] } }
      )
      expect(server.public_net[:firewalls].count).to eq(1)
    end

    it 'with placement_group' do
      server = test_create_with_attribute(
        { placement_group: 42 },
        { placement_group: new_placement_group({ id: 42 }) }
      )
      expect(server.placement_group.id).to eq(42)
    end

    it 'with public_net' do
      # need to stub primary IPs, because public net info will fetch it
      stub_item(:primary_ips, new_primary_ip(id: 1, ip: '192.0.2.0'))
      stub_item(:primary_ips, new_primary_ip(id: 2, ip: '2001:db8::10'))

      server = test_create_with_attribute(
        {
          public_net: {
            enable_ipv4: true,
            enable_ipv6: true,
            ipv4: 1,
            ipv6: 2
          }
        },
        {
          public_net: {
            ipv4: {
              id: 1,
              blocked: false,
              dns_ptr: 'server01.example.com',
              ip: '192.0.2.0'
            },
            ipv6: {
              id: 2,
              blocked: false,
              dns_ptr: 'server01.example.com',
              ip: '2001:db8::10'
            }
          }
        }
      )
      expect(server.public_net[:ipv4].ip).to eq('192.0.2.0')
      expect(server.public_net[:ipv6].ip).to eq('2001:db8::10')
    end

    it 'with volumes' do
      server = test_create_with_attribute(
        { volumes: [42, 43] },
        { volumes: [new_volume({ id: 42 }), new_volume({ id: 43 })] }
      )
      expect(server.volumes.count).to eq(2)
      expect(server.volumes.map(&:id)).to contain_exactly(42, 43)
    end
  end

  it 'get server with volumes' do
    related_action = new_action.merge(action_status(:running))
    stub_collection("servers/#{servers[1][:id]}/actions", [related_action], resource_name: :actions)
    stub('servers', :post) do |_request, _page_info|
      {
        body: { server: servers[1], action: related_action, root_password: :moo },
        code: 201
      }
    end
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(name: 'moo', server_type: 'cx11', image: 1)
    end.not_to(raise_error)

    stub("volumes/#{volumes[0][:id]}") do |_request, _page_info|
      {
        body: { volume: volumes[0] },
        code: 200
      }
    end

    # "attach" volume by adding it to the server double
    servers[1][:volumes] = volumes.map { |volume| volume[:id] }

    # reload server with volume
    stub_item(:servers, servers[1])
    server = client.servers.find(servers[1][:id])
    expect(server.volumes).to be_a Array
    expect(server.volumes).to_not be_empty

    expect(server.volumes.first&.name).to eq(volumes[0][:name])
    expect(server.volumes.first).to be_a Hcloud::Future
  end
end
