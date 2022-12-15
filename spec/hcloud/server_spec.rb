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

    obj = client.servers[server[:id]]

    expect(obj.created).to be_a Time
    expect(obj.datacenter).to be_a Hcloud::Datacenter
    expect(obj.image).to be_a Hcloud::Image unless obj.image.nil?
    expect(obj.iso).to be_a Hcloud::Iso unless obj.iso.nil?
    expect(obj.placement_group).to be_a Hcloud::PlacementGroup unless obj.placement_group.nil?
    expect(obj.server_type).to be_a Hcloud::ServerType
    expect(obj.volumes).to all be_a Hcloud::Volume
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

    it 'with placement_group' do
      params = { name: 'moo', server_type: 'cx11', image: 1, placement_group: 42 }

      expectation = stub('servers', :post) do |request, _page_info|
        expect(request).to have_body_params(a_hash_including({ 'placement_group' => 42 }))

        {
          body: {
            # make sure that even though we create a new random server, the placement group
            # has the right ID in the response
            server: new_server(placement_group: { id: 42 }),
            action: new_action.merge(action_status(:running)),
            root_password: :moo
          },
          code: 201
        }
      end

      _action, server, _pass, _next_actions = client.servers.create(**params)
      expect(expectation.times_called).to eq(1)
      expect(server.placement_group.id).to eq(42)
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
