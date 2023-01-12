# frozen_string_literal: true

require 'spec_helper'

describe 'FloatingIP', :integration, integration_helper: :server do
  let(:fip_name) { resource_name('ip') }

  before(:context) do
    # collect all the floating IPs we create, because we cannot define a name
    # on which we can query for floating IPs
    @ids = []
  end

  it 'fetch floating ips' do
    expect(client.floating_ips.count).to be_a Integer
  end

  it '#create -> invalid type' do
    expect do
      client.floating_ips.create(type: 'moo', home_location: 'nbg1')
    end.to raise_error(Hcloud::Error::InvalidInput)
    expect do
      client.floating_ips.create(type: 'moo', home_location: 'nbg1', server: 1)
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it '#create -> invalid home_location' do
    expect do
      client.floating_ips.create(type: 'ipv4', home_location: 'nbg2')
    end.to raise_error(Hcloud::Error::NotFound)
    expect do
      client.floating_ips.create(type: 'ipv4', home_location: 'nbg2', server: 1)
    end.to raise_error(Hcloud::Error::NotFound)
  end

  it '#create -> invalid server' do
    expect do
      client.floating_ips.create(type: 'ipv4', home_location: 'nbg1', server: 'hui')
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it '#create(type: ipv4, server:)' do
    server_id = client.servers[helper_name].id

    a, f = nil
    expect do
      a, f = client.floating_ips.create(
        type: 'ipv4', server: server_id, labels: { 'source' => 'create' }
      )
    end.not_to raise_error

    expect(a).to be_a Hcloud::Action
    expect(a.status).to eq('running')
    expect(a.command).to eq('assign_floating_ip')

    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to be_a String
    expect(f.blocked).to be false
    expect(f.home_location.name).to be_a String
    expect(f.labels).to eq({ 'source' => 'create' })

    @ids << f.id
  end

  it "#create(type: ipv4, server:, home_location: 'fsn1')" do
    server_id = client.servers[helper_name].id

    a, f = nil
    expect do
      a, f = client.floating_ips.create(type: 'ipv4', home_location: 'fsn1', server: server_id)
    end.not_to raise_error

    expect(a).to be_a Hcloud::Action
    expect(a.status).to eq('running')
    expect(a.command).to eq('assign_floating_ip')

    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to be_a String
    expect(f.blocked).to be false
    expect(f.home_location.name).to be_a String

    @ids << f.id
  end

  it '#create(type: ipv4, home_location: nbg1)' do
    a, f = nil
    expect do
      a, f = client.floating_ips.create(type: 'ipv4', home_location: 'nbg1')
    end.not_to raise_error

    expect(a).to be nil

    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to be_a String
    expect(f.blocked).to be false
    expect(f.home_location.name).to eq('nbg1')

    @ids << f.id
  end

  it '#[] -> find by id' do
    id = client.floating_ips.first.id
    fip = client.floating_ips[id]
    expect(fip).to be_a Hcloud::FloatingIP
    expect(fip.id).to eq(id)
  end

  it '#update(description:)' do
    expect(client.floating_ips.find(@ids[0]).description).to be nil
    expect { client.floating_ips.find(@ids[0]).update(description: fip_name) }.not_to raise_error
    expect(client.floating_ips.find(@ids[0]).description).to eq(fip_name)
  end

  it '#update(labels:)' do
    ip = client.floating_ips.find(@ids[0])
    updated = ip.update(labels: { 'source' => 'update' })
    expect(updated.labels).to eq({ 'source' => 'update' })
    expect(client.floating_ips.find(@ids[0]).labels).to eq({ 'source' => 'update' })
  end

  it '#where -> find by label_selector' do
    ips = client.floating_ips.where(label_selector: 'source=update').to_a
    expect(ips.length).to eq(1)
    expect(ips.first.labels).to include('source' => 'update')
  end

  it '#unassign()' do
    server_id = client.servers[helper_name].id

    expect(client.floating_ips.find(@ids[0]).server).to eq(server_id)
    expect(client.floating_ips.find(@ids[0]).unassign).to be_a Hcloud::Action
    expect(client.floating_ips.find(@ids[0]).server).to be nil
  end

  it '#assign(server:)' do
    server_id = client.servers[helper_name].id

    expect(client.floating_ips.find(@ids[0]).server).to be nil
    expect(client.floating_ips.find(@ids[0]).assign(server: server_id)).to be_a Hcloud::Action
    expect(client.floating_ips.find(@ids[0]).server).to eq(server_id)
  end

  it '#change_dns_ptr' do
    fip = client.floating_ips[@ids[0]]
    expect(fip).to be_a Hcloud::FloatingIP

    expect(fip.change_dns_ptr(ip: fip.ip, dns_ptr: 'moo.example.com')).to be_a Hcloud::Action

    # update floating IP data
    fip = client.floating_ips[@ids[0]]
    expect(fip.dns_ptr.count).to eq(1)
    expect(fip.dns_ptr[0]['ip']).to eq(fip.ip)
    expect(fip.dns_ptr[0]['dns_ptr']).to eq('moo.example.com')
  end

  it '#change_protection' do
    expect(client.floating_ips[@ids[0]]).to be_a Hcloud::FloatingIP
    expect(client.floating_ips[@ids[0]].protection).to be_a Hash
    expect(client.floating_ips[@ids[0]].protection['delete']).to be false

    expect(client.floating_ips[@ids[0]].change_protection(delete: true)).to be_a Hcloud::Action

    expect(client.floating_ips[@ids[0]].protection).to be_a Hash
    expect(client.floating_ips[@ids[0]].protection['delete']).to be true

    # reset to allow delete later
    client.floating_ips[@ids[0]].change_protection(delete: false)
  end

  it '#destroy()' do
    @ids.each do |id|
      to_delete = client.floating_ips[id]
      expect(to_delete).to be_a Hcloud::FloatingIP

      expect { to_delete.destroy }.not_to raise_error
    end
  end
end
