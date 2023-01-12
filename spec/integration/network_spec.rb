# frozen_string_literal: true

require 'spec_helper'

describe 'Network', :integration do
  let(:network_name) { resource_name('network') }

  it 'fetch networks' do
    expect(client.networks.count).to be_a Integer
  end

  it 'create new network, handle missing name' do
    expect { client.networks.create(name: nil, ip_range: '10.0.0.0/16') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new network, handle missing ip_range' do
    expect { client.networks.create(name: network_name, ip_range: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new network' do
    network = client.networks.create(
      name: network_name,
      ip_range: '192.168.0.0/16',
      routes: [{
        destination: '10.0.0.0/24',
        gateway: '192.168.0.10'
      }],
      subnets: [{
        ip_range: '192.168.0.0/24',
        network_zone: 'eu-central',
        type: 'cloud'
      }],
      labels: { 'source' => 'create' }
    )
    expect(network).to be_a Hcloud::Network
    expect(network.id).to be_a Integer
    expect(network.name).to eq(network_name)
    expect(network.routes[0][:destination]).to eq('10.0.0.0/24')
    expect(network.routes[0][:gateway]).to eq('192.168.0.10')
    expect(network.subnets[0][:ip_range]).to eq('192.168.0.0/24')
    expect(network.subnets[0][:network_zone]).to eq('eu-central')
    expect(network.subnets[0][:type]).to eq('cloud')
    expect(network.labels).to eq({ 'source' => 'create' })
  end

  it 'create new network, uniq name' do
    expect { client.networks.create(name: network_name, ip_range: '10.0.0.0/24') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'fetch networks' do
    expect(client.networks.count).to be_an(Integer).and be > 0
  end

  it '#[] -> find by id' do
    expect(client.networks.first).to be_a Hcloud::Network
    id = client.networks.first.id
    expect(id).to be_a Integer
    expect(client.networks[id]).to be_a Hcloud::Network
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
    expect(client.networks[network_name]).to be_a Hcloud::Network
    expect(client.networks[network_name].name).to eq(network_name)
    expect(client.networks[network_name].routes.length).to eq(1)
    expect(client.networks[network_name].subnets.length).to eq(1)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.networks[nonexistent_name]).to be nil
  end

  it '#add_subnet' do
    network = client.networks[network_name]
    expect(network).to be_a Hcloud::Network

    network.add_subnet(
      type: 'cloud',
      network_zone: 'eu-central',
      ip_range: '192.168.1.0/24'
    )

    expect(client.networks[network_name].subnets.length).to eq(2)
  end

  it '#del_subnet' do
    network = client.networks[network_name]
    expect(network).to be_a Hcloud::Network

    network.del_subnet(ip_range: '192.168.1.0/24')
    expect(client.networks[network_name].subnets.length).to eq(1)
  end

  it '#add_route' do
    network = client.networks[network_name]
    expect(network).to be_a Hcloud::Network

    network.add_route(destination: '10.0.1.0/24', gateway: '192.168.0.10')

    expect(client.networks[network_name].routes.length).to eq(2)
  end

  it '#del_route' do
    network = client.networks[network_name]
    expect(network).to be_a Hcloud::Network

    network.del_route(destination: '10.0.1.0/24', gateway: '192.168.0.10')

    expect(client.networks[network_name].routes.length).to eq(1)
  end

  it '#update(name:)' do
    new_name = resource_name('network-new')
    id = client.networks[network_name].id
    expect(id).to be_a Integer
    expect(client.networks.find(id).name).to eq(network_name)
    expect(client.networks.find(id).update(name: new_name).name).to eq(new_name)
    expect(client.networks.find(id).name).to eq(new_name)

    # rename back
    client.networks.find(id).update(name: network_name)
  end

  it '#update(labels:)' do
    id = client.networks.first.id
    network = client.networks[id]
    updated = network.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.networks[id].labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    networks = client.networks.where(label_selector: 'source=update').to_a
    expect(networks.length).to eq(1)
    expect(networks.first.labels).to include('source' => 'update')
  end

  it '#destroy' do
    to_delete = client.networks[network_name]
    expect(to_delete).to be_a Hcloud::Network
    expect(to_delete.destroy).to be_a Hcloud::Network
    expect(client.networks[to_delete.id]).to be nil
  end
end
