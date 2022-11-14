# frozen_string_literal: true

require 'spec_helper'

describe 'Network' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetch networks' do
    expect(client.networks.count).to eq(0)
  end

  it 'create new network, handle missing name' do
    expect { client.networks.create(name: nil, ip_range: '10.0.0.0/16') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new network, handle missing ip_range' do
    expect { client.networks.create(name: 'testnet', ip_range: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new network' do
    network = client.networks.create(
      name: 'testnet',
      ip_range: '192.168.0.0/16',
      routes: [{
        destination: '10.0.0.0/24',
        gateway: '192.168.0.10'
      }],
      subnets: [{
        ip_range: '192.168.0.0/24',
        network_zone: 'eu-central',
        type: 'cloud'
      }]
    )
    expect(network).to be_a Hcloud::Network
    expect(network.id).to be_a Integer
    expect(network.name).to eq('testnet')
    expect(network.routes[0][:destination]).to eq('10.0.0.0/24')
    expect(network.routes[0][:gateway]).to eq('192.168.0.10')
    expect(network.subnets[0][:ip_range]).to eq('192.168.0.0/24')
    expect(network.subnets[0][:network_zone]).to eq('eu-central')
    expect(network.subnets[0][:type]).to eq('cloud')
  end

  it 'create new network, uniq name' do
    expect { client.networks.create(name: 'testnet', ip_range: '10.0.0.0/24') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'fetch networks' do
    expect(client.networks.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.networks.first).to be_a Hcloud::Network
    id = client.networks.first.id
    expect(id).to be_a Integer
    expect(client.networks[id]).to be_a Hcloud::Network
    expect(client.networks[id].name).to eq('testnet')
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.networks[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.networks.first).to be_a Hcloud::Network
    id = client.networks.first.id
    expect(id).to be_a Integer
    expect(client.networks.find(id)).to be_a Hcloud::Network
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.networks.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.networks['testnet']).to be_a Hcloud::Network
    expect(client.networks['testnet'].name).to eq('testnet')
    expect(client.networks['testnet'].routes.length).to eq(1)
    expect(client.networks['testnet'].subnets.length).to eq(1)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.networks['network-missing']).to be nil
  end

  it '#add_subnet' do
    network = client.networks['testnet']
    expect(network).to be_a Hcloud::Network

    network.add_subnet(
      type: 'cloud',
      network_zone: 'eu-central',
      ip_range: '192.168.1.0/24'
    )

    expect(client.networks['testnet'].subnets.length).to eq(2)

    expect(client.actions.count).to eq(1)
    expect(client.networks['testnet'].actions.count).to eq(1)
  end

  it '#del_subnet' do
    network = client.networks['testnet']
    expect(network).to be_a Hcloud::Network

    network.del_subnet(ip_range: '192.168.1.0/24')
    expect(client.networks['testnet'].subnets.length).to eq(1)

    expect(client.actions.count).to eq(2)
    expect(client.networks['testnet'].actions.count).to eq(2)
  end

  it '#add_route' do
    network = client.networks['testnet']
    expect(network).to be_a Hcloud::Network

    network.add_route(destination: '10.0.1.0/24', gateway: '192.168.0.10')

    expect(client.networks['testnet'].routes.length).to eq(2)

    expect(client.actions.count).to eq(3)
    expect(client.networks['testnet'].actions.count).to eq(3)
  end

  it '#del_route' do
    network = client.networks['testnet']
    expect(network).to be_a Hcloud::Network

    network.del_route(destination: '10.0.1.0/24', gateway: '192.168.0.10')

    expect(client.networks['testnet'].routes.length).to eq(1)

    expect(client.actions.count).to eq(4)
    expect(client.networks['testnet'].actions.count).to eq(4)
  end

  it '#update' do
    id = client.networks['testnet'].id
    expect(id).to be_a Integer
    expect(client.networks.find(id).name).to eq('testnet')
    expect(client.networks.find(id).update(name: 'testing').name).to eq('testing')
    expect(client.networks.find(id).name).to eq('testing')
  end

  it '#destroy' do
    expect(client.networks.first).to be_a Hcloud::Network
    id = client.networks.first.id
    expect(id).to be_a Integer
    expect(client.networks.find(id).destroy).to be_a Hcloud::Network
    expect(client.networks[id]).to be nil
  end
end
