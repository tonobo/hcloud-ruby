# frozen_string_literal: true

require 'spec_helper'

describe 'Server' do
  after :all do
    # The test fake for server uses threading with delay to change action status
    # from 'running' to 'success'. To make sure that all threads have completed
    # at the end of the test suite (before we reset the action context and
    # start other tests) we have to sleep a bit.
    sleep(0.5)
  end

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :aclient do
    Hcloud::Client.send(:remove_const, :MAX_ENTRIES_PER_PAGE)
    Hcloud::Client.const_set(:MAX_ENTRIES_PER_PAGE, 1)
    Hcloud::Client.new(token: 'secure', auto_pagination: true)
  end

  let :bclient do
    Hcloud::Client.send(:remove_const, :MAX_ENTRIES_PER_PAGE)
    Hcloud::Client.const_set(:MAX_ENTRIES_PER_PAGE, 2)
    Hcloud::Client.new(token: 'secure', auto_pagination: true)
  end

  it 'fetch server' do
    expect(client.servers.count).to eq(0)
  end

  it 'create new server, handle missing name' do
    expect { client.servers.create(server_type: 'cx11', image: 1) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid name' do
    expect { client.servers.create(server_type: 'cx11', image: 1, name: 'moo_moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle missing server_type' do
    expect { client.servers.create(name: 'moo', image: 1) }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid server_type' do
    expect { client.servers.create(server_type: 'cx111', image: 1, name: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle missing image' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11') }.to(
      raise_error(ArgumentError)
    )
  end

  it 'create new server, handle invalid image' do
    expect { client.servers.create(server_type: 'cx11', image: 1234, name: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle invalid datacenter' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11', image: 1, datacenter: 5) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server, handle invalid location' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11', image: 1, location: 5) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new server' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: 'moo', server_type: 'cx11', image: 1, labels: { 'source' => 'test' }
      )
    end.not_to(raise_error)
    expect(client.actions.per_page(1).page(1).count).to eq(1)
    expect(aclient.actions.count).to eq(1)
    expect(client.actions.per_page(1).page(2).count).to eq(0)
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq('22-02')
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
    expect(server.status).to eq('initalizing')
    expect(server.image.id).to eq(1)
    expect(server.labels).to eq({ 'source' => 'test' })
    expect(action.status).to eq('running')
    expect(action.command).to eq('create_server')
    expect(pass).to eq('test123')
  end

  it 'create new server, custom datacenter' do
    action, server, pass = nil
    expect do
      action, server, pass = bclient.servers.create(
        name: 'foo', server_type: 'cx11', image: 1, datacenter: 2
      )
    end.not_to(raise_error)
    expect(bclient.actions.count).to eq(2)
    expect(server.actions.count).to eq(1)
    expect(server.id).to be_a Integer
    expect(server.datacenter.id).to eq(2)
    expect(action.status).to eq('running')
  end

  it 'create new server, start after init' do
    action, server, pass = nil
    expect do
      action, server, pass = client.servers.create(
        name: 'bar', server_type: 'cx11', image: 1, start_after_create: true
      )
    end.not_to(raise_error)
    expect(server.id).to be_a Integer
    expect(action.status).to eq('running')
  end

  it 'create new server, handle name uniqness' do
    expect { client.servers.create(name: 'moo', server_type: 'cx11', image: 1) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'check succeded servers and actions' do
    expect(client.servers.all? { |x| x.status == 'initalizing' }).to be true
    expect(client.actions.where(status: 'running')
           .select { |x| x.resources.first[:type] == 'server' }.size).to eq(3)
    expect(client.actions.per_page(1).where(status: 'running').count).to eq(1)
    expect(client.actions.per_page(2).where(status: 'running').count).to eq(2)
    expect(client.actions.per_page(2).page(2).where(status: 'running').count).to eq(1)
    expect(client.actions.per_page(2).page(2).count).to eq(1)
    expect(client.actions.per_page(2).page(1).count).to eq(2)
    expect(client.actions.order(:id).map(&:id)).to eq([1, 2, 3])
    expect(client.actions.order(id: :asc).map(&:id)).to eq([1, 2, 3])
    expect(client.actions.order(id: :desc).map(&:id)).to eq([3, 2, 1])
    expect { client.actions.order(1).map(&:id) }.to raise_error(ArgumentError)
    expect(client.actions.per_page(1).page(1).all.pagination.total_entries).to eq(3)
    expect(client.actions.per_page(1).page(1).all.pagination.last_page).to eq(3)
    expect(client.actions.per_page(1).page(1).all.pagination.next_page).to eq(2)
    expect(client.actions.per_page(1).page(1).all.pagination.previous_page).to be nil
    expect(client.actions.per_page(1).page(2).all.pagination.next_page).to eq(3)
    expect(client.actions.per_page(1).page(2).all.pagination.previous_page).to eq(1)
    expect(client.actions.per_page(1).page(3).all.pagination.next_page).to be nil
    expect(client.actions.per_page(1).page(3).all.pagination.previous_page).to eq(2)
    expect(client.actions.per_page(10).page(3).count).to eq(0)
    expect(aclient.actions.count).to eq(3)
    expect(bclient.actions.limit(3).count).to eq(3)
    expect(aclient.actions.limit(2).count).to eq(2)
    expect(aclient.actions.limit(3).count).to eq(3)
    expect(aclient.actions.limit(4).count).to eq(3)
    expect(aclient.actions.all.pagination).to eq(:auto)
    sleep(0.6)
    expect(client.servers.none? { |x| x.status == 'initalizing' }).to be true
    expect(client.servers.group_by(&:status).transform_values(&:size)).to(
      eq('off' => 2, 'running' => 1)
    )
    expect(client.actions.where(status: 'success')
           .select { |x| x.resources.first[:type] == 'server' }.size).to eq(3)
  end

  it '#find()' do
    server = client.servers.find(1)
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq('22-02')
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end

  it '#find() -> handle error' do
    expect { client.servers.find(0) }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#find_by(name:)' do
    server = client.servers.find_by(name: 'moo')
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq('22-02')
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end

  it '#[string]' do
    server = client.servers['moo']
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq('22-02')
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end

  it '#[string] -> handle nil' do
    expect(client.servers['']).to be nil
  end

  it '#[integer]' do
    server = client.servers[1]
    expect(server.id).to be_a Integer
    expect(server.name).to eq('moo')
    expect(server.rescue_enabled).to be false
    expect(server.backup_window).to eq('22-02')
    expect(server.datacenter.id).to eq(1)
    expect(server.locked).to be false
    expect(server.iso).to be nil
    expect(server.created).to be_a Time
    expect(server.outgoing_traffic).to eq(123)
    expect(server.ingoing_traffic).to eq(123)
    expect(server.included_traffic).to eq(123)
    expect(server.image.id).to eq(1)
  end

  it '#[integer] -> handle nil' do
    expect(client.servers[0]).to be nil
  end

  it '#update(name:)' do
    expect(client.servers.find(1).name).to eq('moo')
    server = nil
    expect { server = client.servers[1].update(name: 'foo') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
    expect { server = client.servers[1].update(name: 'hui') }.not_to raise_error
    expect(server.name).to eq('hui')
    expect(client.servers.find(1).name).to eq('hui')
  end

  it '#update(labels:)' do
    server = client.servers.find(1)
    updated = server.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.servers.find(1).labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    servers = client.servers.where(label_selector: 'source=update').to_a
    expect(servers.length).to eq(1)
    expect(servers.first.labels).to include('source' => 'update')
  end

  it '#destroy' do
    action = nil
    expect { action = client.servers[1].destroy }.not_to raise_error
    expect(action.status).to eq('success')
    expect(client.servers[1]).to be nil
  end

  it 'check server actions' do
    expect(client.servers[2].actions.count).to eq(1)
    expect(id = client.servers[2].actions.first.id).to be_a Integer
    expect(client.servers[2].actions[id].id).to eq(id)
  end

  it '#poweroff' do
    expect(client.servers[2].poweroff).to be_a Hcloud::Action
    expect(client.servers[2].actions.count { |x| x.command == 'stop_server' }).to eq(1)
  end

  it '#poweron' do
    expect { client.servers[2].poweron }.to raise_error(Hcloud::Error::Locked)
    sleep(0.5)
    expect(client.servers[2].status).to eq('off')
    expect(client.servers[2].poweron).to be_a Hcloud::Action
    expect(client.servers[2].actions.count { |x| x.command == 'start_server' }).to eq(1)
  end

  it '#reset_password' do
    expect { client.servers[2].reset_password }.to raise_error(Hcloud::Error::Locked)
    sleep(0.5)
    action, pass = nil
    expect { action, pass = client.servers[2].reset_password }.not_to raise_error
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('reset_password')
    expect(action.status).to eq('running')
    expect(pass).to eq('test123')
  end

  it '#request_console' do
    expect { client.servers[2].request_console }.to raise_error(Hcloud::Error::Locked)
    sleep(0.5)
    action, url, pass = nil
    expect { action, url, pass = client.servers[2].request_console }.not_to raise_error
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('request_console')
    expect(action.status).to eq('running')
    expect(url).to eq("wss://web-console.hetzner.cloud/?server_id=#{client.servers[2].id}&token=token")
    expect(pass).to eq('test123')
  end

  it '#enable_rescue' do
    expect { client.servers[2].enable_rescue(type: 'moo') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
    expect { client.servers[2].enable_rescue }.to(
      raise_error(Hcloud::Error::Locked)
    )
    sleep(0.5)
    action, pass = nil
    expect { action, pass = client.servers[2].enable_rescue(type: 'linux32') }.not_to raise_error
    expect(action).to be_a Hcloud::Action
    expect(action.command).to eq('enable_rescue')
    expect(action.status).to eq('running')
    expect(pass).to eq('test123')
  end

  it '#change_protection' do
    expect(client.servers[2]).to be_a Hcloud::Server
    expect(client.servers[2].protection).to be_a Hash
    expect(client.servers[2].protection['delete']).to be false
    expect(client.servers[2].protection['rebuild']).to be false

    expect(client.servers[2].change_protection).to be_a Hcloud::Action

    expect(client.servers[2].protection).to be_a Hash
    expect(client.servers[2].protection['delete']).to be false

    expect(client.servers[2].change_protection(delete: true)).to be_a Hcloud::Action

    expect(client.servers[2].protection).to be_a Hash
    expect(client.servers[2].protection['delete']).to be true
  end

  it '#create_image' do
    expect(client.servers[2]).to be_a Hcloud::Server
    action, image = client.servers[2].create_image(description: 'test image', type: 'snapshot')
    expect(image.description).to eq('test image')
    expect(image.type).to eq('snapshot')
    expect(action.command).to eq('create_image')
  end
end
