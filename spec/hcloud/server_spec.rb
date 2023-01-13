# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'
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
  include_examples 'it_supports_action_fetch', described_class

  it 'fetch server' do
    stub_collection :servers, []
    expect(client.servers.count).to eq(0)
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

  it 'create new server' do
    related_action = new_action.merge(action_status(:running))
    stub_collection("servers/#{servers[0][:id]}/actions", [related_action], resource_name: :actions)
    stub('servers') do |_request, _page_info|
      {
        body: { server: servers[0], action: related_action, root_password: :moo },
        code: 201
      }
    end
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(name: 'moo', server_type: 'cx11', image: 1)
    end.not_to(raise_error)
    expect(server.actions.count).to eq(1)
    expect(server.id).to be_a Integer
    expect(server.rescue_enabled).to be servers[0][:rescue_enabled]
    expect(server.datacenter.id).to eq(servers[0].dig(:datacenter, :id))
    expect(server.created).to be_a Time
    expect(action.status).to eq('running')
    expect(pass).to eq('moo')
    expect(server.volumes).to be_a Array
    expect(server.volumes).to be_empty

    expect(server.private_net).to_not be_empty
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
