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
    client.images.first
  end

  let :sample_datacenter do
    client.datacenters['fsn1-dc14']
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
    expect { client.servers.create(name: 'moo', image: sample_image.id) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid server_type' do
    expect { client.servers.create(server_type: 'cx111', image: sample_image.id, name: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle missing image' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11') }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid image' do
    expect { client.servers.create(server_type: 'cx11', image: 0, name: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle invalid datacenter' do
    expect do
      client.servers.create(
        name: 'moo',
        server_type: 'cx11',
        image: sample_image.id,
        datacenter: 0
      )
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it 'create new server, handle invalid location' do
    expect do
      client.servers.create(
        name: 'moo',
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
        name: 'moo',
        server_type: 'cx11',
        image: sample_image.id,
        labels: { 'source' => 'test' }
      )
    end.not_to(raise_error)
    expect(action).to be_a Hcloud::Action
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.datacenter.id).to be_a Integer
    expect(server.locked).to be false
    expect(server.created).to be_a Time
    expect(server.image.id).to eq(sample_image.id)
    expect(server.status).to eq('initializing')
    expect(server.labels).to eq({ 'source' => 'test' })
    expect(action.status).to eq('running')
    expect(action.command).to eq('create_server')
    expect(pass).to be_a String
  end

  it 'create new server, custom datacenter' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: 'foo',
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
        name: 'bar', server_type: 'cx11', image: sample_image.id, start_after_create: true
      )
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(action.status).to eq('running')
  end

  it 'create new server, handle name uniqness' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11', image: sample_image.id) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it '#find()' do
    id = client.servers.first.id
    server = client.servers.find(id)
    expect(server.id).to be_a Integer
    expect(server.name).to be_a String
    expect(server.rescue_enabled).to be_in([true, false])
    expect(server.datacenter.id).to be_a Integer
    expect(server.locked).to be_in([true, false])
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to be_a Integer
    expect(server.ingoing_traffic).to be_a Integer
    expect(server.included_traffic).to be_a Integer
    expect(server.image.id).to be_a Integer
  end

  it '#find() -> handle error' do
    expect { client.servers.find(0) }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#find_by(name:)' do
    server = client.servers.find_by(name: 'moo')
    expect(server.name).to eq('moo')
  end

  it '#[string]' do
    server = client.servers['moo']
    expect(server.name).to eq('moo')
  end

  it '#[string] -> handle nil' do
    expect(client.servers['someinvalidservername']).to be nil
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
    id = client.servers['moo'].id
    server = nil
    expect { server = client.servers[id].update(name: 'foo') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
    expect { server = client.servers[id].update(name: 'hui') }.not_to raise_error
    expect(server.name).to eq('hui')
    expect(client.servers.find(id).name).to eq('hui')
  end

  it '#update(labels:)' do
    server = client.servers['hui']
    updated = server.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.servers['hui'].labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    servers = client.servers.where(label_selector: 'source=update').to_a
    expect(servers.length).to eq(1)
    expect(servers.first.labels).to include('source' => 'update')
  end

  #it '#poweroff' do
  #  expect(client.servers[2].poweroff).to be_a Hcloud::Action
  #  expect(client.servers[2].actions.count { |x| x.command == 'stop_server' }).to eq(1)
  #end

  #it '#poweron' do
  #  expect { client.servers[2].poweron }.to raise_error(Hcloud::Error::Locked)
  #  sleep(0.5)
  #  expect(client.servers[2].status).to eq('off')
  #  expect(client.servers[2].poweron).to be_a Hcloud::Action
  #  expect(client.servers[2].actions.count { |x| x.command == 'start_server' }).to eq(1)
  #end

  #it '#reset_password' do
  #  expect { client.servers[2].reset_password }.to raise_error(Hcloud::Error::Locked)
  #  sleep(0.5)
  #  action, pass = nil
  #  expect { action, pass = client.servers[2].reset_password }.not_to raise_error
  #  expect(action).to be_a Hcloud::Action
  #  expect(action.command).to eq('reset_password')
  #  expect(action.status).to eq('running')
  #  expect(pass).to eq('test123')
  #end

  #it '#request_console' do
  #  expect { client.servers[2].request_console }.to raise_error(Hcloud::Error::Locked)
  #  sleep(0.5)
  #  action, url, pass = nil
  #  expect { action, url, pass = client.servers[2].request_console }.not_to raise_error
  #  expect(action).to be_a Hcloud::Action
  #  expect(action.command).to eq('request_console')
  #  expect(action.status).to eq('running')
  #  expect(url).to eq("wss://web-console.hetzner.cloud/?server_id=#{client.servers[2].id}&token=token")
  #  expect(pass).to eq('test123')
  #end

  #it '#enable_rescue' do
  #  expect { client.servers[2].enable_rescue(type: 'moo') }.to(
  #    raise_error(Hcloud::Error::InvalidInput)
  #  )
  #  expect { client.servers[2].enable_rescue }.to(
  #    raise_error(Hcloud::Error::Locked)
  #  )
  #  sleep(0.5)
  #  action, pass = nil
  #  expect { action, pass = client.servers[2].enable_rescue(type: 'linux32') }.not_to raise_error
  #  expect(action).to be_a Hcloud::Action
  #  expect(action.command).to eq('enable_rescue')
  #  expect(action.status).to eq('running')
  #  expect(pass).to eq('test123')
  #end

  #it '#change_protection' do
  #  expect(client.servers[2]).to be_a Hcloud::Server
  #  expect(client.servers[2].protection).to be_a Hash
  #  expect(client.servers[2].protection['delete']).to be false
  #  expect(client.servers[2].protection['rebuild']).to be false

  #  expect(client.servers[2].change_protection).to be_a Hcloud::Action

  #  expect(client.servers[2].protection).to be_a Hash
  #  expect(client.servers[2].protection['delete']).to be false

  #  expect(client.servers[2].change_protection(delete: true)).to be_a Hcloud::Action

  #  expect(client.servers[2].protection).to be_a Hash
  #  expect(client.servers[2].protection['delete']).to be true
  #end

  #it '#create_image' do
  #  expect(client.servers[2]).to be_a Hcloud::Server
  #  action, image = client.servers[2].create_image(description: 'test image', type: 'snapshot')
  #  expect(image.description).to eq('test image')
  #  expect(image.type).to eq('snapshot')
  #  expect(action.command).to eq('create_image')
  #end

  it '#destroy' do
    %w[hui foo bar].each do |name|
      id = client.servers[name].id
      expect { client.servers[id].destroy }.not_to raise_error
      expect(client.servers[id]).to be nil
    end
  end
end
