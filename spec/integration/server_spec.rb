# frozen_string_literal: true

require 'spec_helper'

describe 'Server', :integration do
  after :all do
    # The test fake for server uses threading with delay to change action status
    # from 'running' to 'success'. To make sure that all threads have completed
    # at the end of the test suite (before we reset the action context and
    # start other tests) we have to sleep a bit.
    sleep(0.5)
  end

  let :sample_image do
    # use a well known image, because a randomly chosen image might not have guest agent
    # (guest agent is required to reset password)
    client.images['ubuntu-22.04']
  end

  let :sample_datacenter do
    client.datacenters['fsn1-dc14']
  end

  let :server_name do
    resource_name('server')
  end

  it 'fetch server' do
    expect(client.servers.count).to be_a Integer
  end

  it 'create new server, handle missing name' do
    expect { client.servers.create(server_type: 'cx11', image: sample_image.id) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid name' do
    expect do
      client.servers.create(server_type: 'cx11', image: sample_image.id, name: 'moo_moo')
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it 'create new server, handle missing server_type' do
    expect { client.servers.create(name: server_name, image: sample_image.id) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid server_type' do
    expect do
      client.servers.create(server_type: 'cx111', image: sample_image.id, name: server_name)
    end.to(raise_error(Hcloud::Error::InvalidInput))
  end

  it 'create new server, handle missing image' do
    expect { client.servers.create(name: server_name, server_type: 'cx11') }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid image' do
    expect { client.servers.create(server_type: 'cx11', image: 0, name: server_name) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle invalid datacenter' do
    expect do
      client.servers.create(
        name: server_name,
        server_type: 'cx11',
        image: sample_image.id,
        datacenter: 0
      )
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it 'create new server, handle invalid location' do
    expect do
      client.servers.create(
        name: server_name,
        server_type: 'cx11',
        image: sample_image.id,
        location: 0
      )
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it 'create new server' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: server_name,
        server_type: 'cx11',
        image: sample_image.id,
        labels: { 'source' => 'test' }
      )
    end.not_to(raise_error)
    expect(action).to be_a Hcloud::Action
    expect(server.id).to be_a Integer
    expect(server.name).to eq(server_name)
    expect(server.datacenter.id).to be_a Integer
    expect(server.locked).to be false
    expect(server.created).to be_a Time
    expect(server.image.id).to eq(sample_image.id)
    expect(server.status).to eq('initializing')
    expect(server.labels).to eq({ 'source' => 'test' })
    expect(action.status).to eq('running')
    expect(action.command).to eq('create_server')
    expect(pass).to be_a String

    wait_for_action(client.servers[server_name], action.id)
  end

  it 'create new server, custom datacenter' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: resource_name('server2'),
        server_type: 'cx11',
        image: sample_image.id,
        datacenter: sample_datacenter.id
      )
    end.not_to(raise_error)
    expect(action).to be_a Hcloud::Action
    expect(server.actions.count).to be_a Integer
    expect(server.id).to be_a Integer
    expect(server.datacenter.id).to eq(sample_datacenter.id)
    expect(action.status).to eq('running')
  end

  it 'create new server, start after init' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: resource_name('server3'),
        server_type: 'cx11',
        image: sample_image.id,
        start_after_create: true
      )
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(action.status).to eq('running')
  end

  it 'create new server, handle name uniqness' do
    expect do
      client.servers.create(name: server_name, server_type: 'cx11', image: sample_image.id)
    end.to(raise_error(Hcloud::Error::UniquenessError))
  end

  it '#find()' do
    id = client.servers.first.id
    server = client.servers.find(id)
    expect(server).to be_a Hcloud::Server
    expect(server.id).to eq(id)
  end

  it '#find() -> handle error' do
    expect { client.servers.find(0) }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#find_by(name:)' do
    server = client.servers.find_by(name: server_name)
    expect(server.name).to eq(server_name)
  end

  it '#[string]' do
    server = client.servers[server_name]
    expect(server.name).to eq(server_name)
  end

  it '#[string] -> handle nil' do
    expect(client.servers[nonexistent_name]).to be nil
  end

  it '#[integer]' do
    id = client.servers.first.id
    server = client.servers[id]
    expect(server.id).to eq(id)
  end

  it '#[integer] -> handle nil' do
    expect(client.servers[0]).to be nil
  end

  it '#update(name:)' do
    new_name = resource_name('server-new')
    id = client.servers[server_name].id
    server = nil
    expect { server = client.servers[id].update(name: resource_name('server2')) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
    expect { server = client.servers[id].update(name: new_name) }.not_to raise_error
    expect(server.name).to eq(new_name)
    expect(client.servers.find(id).name).to eq(new_name)

    # rename back
    server = client.servers[id].update(name: server_name)
  end

  it '#update(labels:)' do
    server = client.servers[server_name]
    updated = server.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.servers[server_name].labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    servers = client.servers.where(label_selector: 'source=update').to_a
    expect(servers.length).to eq(1)
    expect(servers.first.labels).to include('source' => 'update')
  end

  it '#reset_password' do
    # server might need some time until guest agent is installed
    sleep 30

    action, pass = client.servers[server_name].reset_password

    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('reset_server_password')
    expect(pass).to be_a String

    wait_for_action(client.servers[server_name], action.id)
  end

  it '#request_console' do
    action, url, pass = client.servers[server_name].request_console

    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('request_console')
    expect(url).to match(%r{wss://.+})
    expect(pass).to be_a String

    wait_for_action(client.servers[server_name], action.id)
  end

  it '#enable_rescue' do
    expect { client.servers[server_name].enable_rescue(type: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )

    action, pass = client.servers[server_name].enable_rescue(type: 'linux32')
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('enable_rescue')
    expect(pass).to be_a String

    wait_for_action(client.servers[server_name], action.id)
  end

  it '#change_protection' do
    expect(client.servers[server_name].protection).to be_a Hash
    expect(client.servers[server_name].protection['delete']).to be false
    expect(client.servers[server_name].protection['rebuild']).to be false

    expect(client.servers[server_name].change_protection(rebuild: true, delete: true)).to \
      be_a Hcloud::Action

    expect(client.servers[server_name].protection).to be_a Hash
    expect(client.servers[server_name].protection['delete']).to be true

    # unprotect to allow deletion later
    client.servers[server_name].change_protection(rebuild: false, delete: false)
  end

  it '#create_image' do
    image_name = resource_name('server-image')

    expect(client.servers[server_name]).to be_a Hcloud::Server
    action, image = client.servers[server_name].create_image(
      description: image_name, type: 'snapshot'
    )
    expect(image.description).to eq(image_name)
    expect(image.type).to eq('snapshot')
    expect(action.command).to eq('create_image')

    wait_for_action(client.servers[server_name], action.id)

    # delete the image again
    client.images[image.id].destroy
  end

  it '#poweroff' do
    action = client.servers[server_name].poweroff

    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('stop_server')

    wait_for_action(client.servers[server_name], action.id)

    expect(client.servers[server_name].status).to eq('off')
  end

  it '#poweron' do
    action = client.servers[server_name].poweron

    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('start_server')

    wait_for_action(client.servers[server_name], action.id)

    expect(client.servers[server_name].status).to eq('running')
  end

  it '#destroy' do
    [server_name, resource_name('server2'), resource_name('server3')].each do |name|
      id = client.servers[name].id
      expect { client.servers[id].destroy }.not_to raise_error
      expect(client.servers[id]).to be nil
    end
  end
end
