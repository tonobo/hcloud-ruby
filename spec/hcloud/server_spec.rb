# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hcloud::Server, doubles: :server do
  include_context 'test doubles'

  let :servers do
    Array.new(Faker::Number.within(range: 20..150)).map { new_server }
  end

  let :volumes do
    Array.new(Faker::Number.within(range: 2..10)).map { new_volume }
  end

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
      expect(Oj.load(request.options[:body], symbol_keys: true)).to include(
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
    stub('servers') do |_request, _page_info|
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
    server = client.servers.find(servers[1][:id])
    expect(server.volumes).to be_a Array
    expect(server.volumes).to_not be_empty

    expect(server.volumes.first).to eq(volumes[0])
    expect(server.volumes).to eq(volumes)
  end
end
