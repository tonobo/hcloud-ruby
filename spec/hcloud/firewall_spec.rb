# frozen_string_literal: true

require 'spec_helper'

describe 'Firewall' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetch firewalls' do
    expect(client.firewalls.count).to eq(0)
  end

  it 'create new firewall, handle missing name' do
    expect { client.firewalls.create(name: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new firewall, only name' do
    firewall = client.firewalls.create(name: 'fw')
    expect(firewall).to be_a Hcloud::Firewall
    expect(firewall.id).to be_a Integer
    expect(firewall.name).to eq('fw')
  end

  it 'create new firewall, uniq name' do
    expect { client.firewalls.create(name: 'fw') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'create new firewall, with rules and apply_to' do
    rules = [{
      'protocol' => 'tcp',
      'source_ips' => ['192.0.2.0/24'],
      'port' => 80,
      'direction' => 'in',
      'description' => 'HTTP access'
    }]
    apply_to = [{
      'server' => {
        'id' => 1
      },
      'type' => 'server'
    }]
    firewall = client.firewalls.create(
      name: 'fw-rules',
      rules: rules,
      apply_to: apply_to,
      labels: { 'source' => 'unittest' }
    )
    expect(firewall).to be_a Hcloud::Firewall
    expect(firewall.id).to be_a Integer
    expect(firewall.name).to eq('fw-rules')
    expect(firewall.labels).to eq({ 'source' => 'unittest' })
    expect(firewall.rules.length).to eq(1)
    expect(firewall.rules[0]['protocol']).to eq('tcp')
    expect(firewall.rules[0]['source_ips']).to eq(['192.0.2.0/24'])
    expect(firewall.rules[0]['port']).to eq(80)
    expect(firewall.rules[0]['direction']).to eq('in')
    expect(firewall.rules[0]['description']).to eq('HTTP access')
    expect(firewall.applied_to.length).to eq(1)
    expect(firewall.applied_to[0]['server']['id']).to eq(1)
    expect(firewall.applied_to[0]['type']).to eq('server')
  end

  it 'fetch firewalls' do
    expect(client.firewalls.count).to eq(2)
  end

  it '#[] -> find by id' do
    expect(client.firewalls.first).to be_a Hcloud::Firewall
    id = client.firewalls.first.id
    expect(id).to be_a Integer
    expect(client.firewalls[id]).to be_a Hcloud::Firewall
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.firewalls[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.firewalls.first).to be_a Hcloud::Firewall
    id = client.firewalls.first.id
    expect(id).to be_a Integer
    expect(client.firewalls.find(id)).to be_a Hcloud::Firewall
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.firewalls.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.firewalls['fw']).to be_a Hcloud::Firewall
    expect(client.firewalls['fw'].name).to eq('fw')
    expect(client.firewalls['fw'].rules.length).to eq(0)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.firewalls['fw-missing']).to be nil
  end

  it '#set_rules' do
    rules = [{
      'protocol' => 'tcp',
      'source_ips' => ['192.0.2.0/30'],
      'port' => 21,
      'direction' => 'in',
      'description' => 'FTP access'
    }]
    action = client.firewalls['fw'].set_rules(rules: rules)

    expect(client.firewalls['fw'].rules.length).to eq(1)
    expect(client.firewalls['fw'].rules[0][:protocol]).to eq('tcp')
    expect(client.firewalls['fw'].rules[0][:source_ips]).to eq(['192.0.2.0/30'])
    expect(client.firewalls['fw'].rules[0][:port]).to eq(21)
    expect(client.firewalls['fw'].rules[0][:direction]).to eq('in')
    expect(client.firewalls['fw'].rules[0][:description]).to eq('FTP access')

    expect(client.actions.count).to eq(1)
    expect(client.firewalls['fw'].actions.count).to eq(1)
    expect(action.command).to eq('set_rules')
  end

  it '#set_rules, missing rules' do
    expect { client.firewalls['fw'].set_rules(rules: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#apply_to_resources' do
    apply_to = [{
      'server' => {
        'id' => 42
      },
      'type' => 'server'
    }, {
      'server' => {
        'id' => 1
      },
      'type' => 'server'
    }]
    action = client.firewalls['fw'].apply_to_resources(apply_to: apply_to)

    expect(client.firewalls['fw'].applied_to.length).to eq(2)
    expect(client.firewalls['fw'].applied_to.map { |res| res[:server][:id] }).to eq([42, 1])

    expect(client.actions.count).to eq(2)
    expect(client.firewalls['fw'].actions.count).to eq(2)
    expect(action.command).to eq('apply_to_resources')
  end

  it '#apply_to_resources, missing apply_to' do
    expect { client.firewalls['fw'].apply_to_resources(apply_to: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#remove_from_resources' do
    remove_from = [{
      'server' => {
        'id' => 1
      },
      'type' => 'server'
    }]
    action = client.firewalls['fw'].remove_from_resources(remove_from: remove_from)

    expect(client.firewalls['fw'].applied_to.length).to eq(1)
    expect(client.firewalls['fw'].applied_to[0][:server][:id]).to eq(42)

    expect(client.actions.count).to eq(3)
    expect(client.firewalls['fw'].actions.count).to eq(3)
    expect(action.command).to eq('remove_from_resources')
  end

  it '#remove_from_resources, missing remove_from' do
    expect { client.firewalls['fw'].remove_from_resources(remove_from: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#update(name:)' do
    id = client.firewalls['fw'].id
    expect(id).to be_a Integer
    expect(client.firewalls.find(id).name).to eq('fw')
    expect(client.firewalls.find(id).update(name: 'firewall').name).to eq('firewall')
    expect(client.firewalls.find(id).name).to eq('firewall')
  end

  it '#update(labels:)' do
    id = client.firewalls['firewall'].id
    firewall = client.firewalls[id]
    updated = firewall.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.firewalls[id].labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    firewalls = client.firewalls.where(label_selector: 'source=update').to_a
    expect(firewalls.length).to eq(1)
    expect(firewalls.first.labels).to include('source' => 'update')
  end

  it '#destroy' do
    expect(client.firewalls.first).to be_a Hcloud::Firewall
    id = client.firewalls.first.id
    expect(id).to be_a Integer
    expect(client.firewalls.find(id).destroy).to be_a Hcloud::Firewall
    expect(client.firewalls[id]).to be nil
  end
end
