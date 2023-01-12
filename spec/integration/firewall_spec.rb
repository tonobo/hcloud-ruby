# frozen_string_literal: true

require 'spec_helper'

describe 'Firewall', :integration, integration_helper: :server do
  let(:firewall_name) { resource_name('firewall') }

  it 'create new firewall, handle missing name' do
    expect { client.firewalls.create(name: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new firewall, only name' do
    actions, firewall = client.firewalls.create(name: firewall_name)
    expect(actions).to all(be_a(Hcloud::Action))
    expect(firewall).to be_a Hcloud::Firewall
    expect(firewall.name).to eq(firewall_name)
  end

  it 'fetch firewalls' do
    # there must be at least one after we have created one
    expect(client.firewalls.count).to be_an(Integer).and be > 0
    expect(client.firewalls).to all(be_a(Hcloud::Firewall))
  end

  it 'create new firewall, uniq name' do
    expect { client.firewalls.create(name: firewall_name) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'create new firewall, with rules and apply_to' do
    rules = [{
      'protocol' => 'tcp',
      'source_ips' => ['192.0.2.0/24'],
      'port' => '80',
      'direction' => 'in',
      'description' => 'HTTP access'
    }]
    server_id = client.servers[helper_name].id
    apply_to = [{
      'server' => {
        'id' => server_id
      },
      'type' => 'server'
    }]
    actions, firewall = client.firewalls.create(
      name: resource_name('firewall2'),
      rules: rules,
      apply_to: apply_to,
      labels: { 'source' => 'unittest' }
    )

    expect(actions).to all(be_a(Hcloud::Action))
    actions.each do |action|
      wait_for_action(firewall, action.id)
    end

    firewall = client.firewalls[resource_name('firewall2')]
    expect(firewall).to be_a Hcloud::Firewall
    expect(firewall.id).to be_a Integer
    expect(firewall.name).to eq(resource_name('firewall2'))
    expect(firewall.labels).to eq({ 'source' => 'unittest' })
    expect(firewall.rules.length).to eq(1)
    expect(firewall.rules[0]['protocol']).to eq('tcp')
    expect(firewall.rules[0]['source_ips']).to eq(['192.0.2.0/24'])
    expect(firewall.rules[0]['port']).to eq('80')
    expect(firewall.rules[0]['direction']).to eq('in')
    expect(firewall.rules[0]['description']).to eq('HTTP access')
    expect(firewall.applied_to.length).to eq(1)
    expect(firewall.applied_to[0]['server']['id']).to eq(server_id)
    expect(firewall.applied_to[0]['type']).to eq('server')

    # remove firewall from server or we cannot delete the firewall later
    remove_from = [{
      'server' => {
        'id' => server_id
      },
      'type' => 'server'
    }]
    actions = firewall.remove_from_resources(remove_from: remove_from)
    wait_for_action(firewall, actions[0].id)
  end

  it '#[] -> find by id' do
    expect(client.firewalls[client.firewalls.first.id]).to be_a Hcloud::Firewall
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.firewalls[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.firewalls.find(client.firewalls.first.id)).to be_a Hcloud::Firewall
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.firewalls.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.firewalls[firewall_name]).to be_a Hcloud::Firewall
    expect(client.firewalls[firewall_name].name).to eq(firewall_name)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.firewalls[resource_name('firewall-missing')]).to be nil
  end

  it '#set_rules' do
    rules = [{
      'protocol' => 'tcp',
      'source_ips' => ['192.0.2.0/30'],
      'port' => '21',
      'direction' => 'in',
      'description' => 'FTP access'
    }]
    actions = client.firewalls[firewall_name].set_rules(rules: rules)
    expect(actions.count).to be_a(Integer).and be > 0
    expect(actions).to all(be_a(Hcloud::Action))

    firewall = client.firewalls[firewall_name]
    expect(firewall.rules.length).to eq(1)
    expect(firewall.rules[0][:protocol]).to eq('tcp')
    expect(firewall.rules[0][:source_ips]).to eq(['192.0.2.0/30'])
    expect(firewall.rules[0][:port]).to eq('21')
    expect(firewall.rules[0][:direction]).to eq('in')
    expect(firewall.rules[0][:description]).to eq('FTP access')
  end

  it '#apply_to_resources' do
    server_id = client.servers[helper_name].id
    apply_to = [{
      'server' => {
        'id' => server_id
      },
      'type' => 'server'
    }]

    actions = nil
    expect do
      actions = client.firewalls[firewall_name].apply_to_resources(apply_to: apply_to)
    end.to change { client.firewalls[firewall_name].actions.count }.by(1)

    expect(actions).to all(be_a(Hcloud::Action))
    expect(actions[0].command).to eq('apply_firewall')

    firewall = client.firewalls[firewall_name]
    expect(firewall.applied_to.length).to eq(1)
    expect(firewall.applied_to[0][:server][:id]).to eq(server_id)

    wait_for_action(firewall, actions[0].id)
  end

  it '#apply_to_resources, missing apply_to' do
    expect { client.firewalls[firewall_name].apply_to_resources(apply_to: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#remove_from_resources' do
    firewall = client.firewalls[firewall_name]
    server_id = client.servers[helper_name].id

    remove_from = [{
      'server' => {
        'id' => server_id
      },
      'type' => 'server'
    }]

    actions = nil
    expect do
      actions = firewall.remove_from_resources(remove_from: remove_from)
    end.to change { firewall.actions.count }.by(1)

    expect(actions).to all(be_a(Hcloud::Action))
    expect(actions[0].command).to eq('remove_firewall')

    firewall = client.firewalls[firewall_name]
    expect(firewall.applied_to.length).to eq(0)

    wait_for_action(firewall, actions[0].id)
  end

  it '#remove_from_resources, missing remove_from' do
    expect { client.firewalls[firewall_name].remove_from_resources(remove_from: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#update(name:)' do
    id = client.firewalls[firewall_name].id
    new_name = resource_name('firewall-new')

    expect(client.firewalls.find(id).name).to eq(firewall_name)
    expect(client.firewalls.find(id).update(name: new_name).name).to eq(new_name)
    expect(client.firewalls.find(id).name).to eq(new_name)
  end

  it '#update(labels:)' do
    id = client.firewalls[resource_name('firewall-new')].id

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
    [resource_name('firewall-new'), resource_name('firewall2')].each do |name|
      to_delete = client.firewalls[name]
      expect(to_delete).to be_a Hcloud::Firewall
      expect(to_delete.destroy).to be_a Hcloud::Firewall
      expect(client.firewalls[to_delete.id]).to be nil
    end
  end
end
