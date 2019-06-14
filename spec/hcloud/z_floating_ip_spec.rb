require 'spec_helper'

describe 'FloatingIP' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetch floating ips' do
    expect(client.floating_ips.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.floating_ips.first).to be_a Hcloud::FloatingIP
    id = client.floating_ips.first.id
    expect(id).to be_a Integer
    expect(client.floating_ips[id]).to be_a Hcloud::FloatingIP
    expect(client.floating_ips[id].description).to be_a String
    expect(client.floating_ips[id].type).to be_a String
    expect(client.floating_ips[id].ip).to be_a String
    expect(client.floating_ips[id].server).to be nil
    expect(client.floating_ips[id].blocked).to be false
    expect(client.floating_ips[id].home_location.id).to eq(2)
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
    end.to raise_error(Hcloud::Error::InvalidInput)
    expect do
      client.floating_ips.create(type: 'ipv4', home_location: 'nbg2', server: 1)
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it '#create -> invalid server' do
    expect do
      client.floating_ips.create(type: 'ipv4', home_location: 'nbg1', server: 'hui')
    end.to raise_error(Hcloud::Error::InvalidInput)
  end

  it '#create(type: ipv4, server: 1)' do
    a, f = nil
    expect do
      a, f = client.floating_ips.create(type: 'ipv4', server: 1)
    end.not_to raise_error
    expect(a).to be_a Hcloud::Action
    expect(a.status).to eq('running')
    expect(a.command).to eq('assign_floating_ip')
    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to eq('127.0.0.2')
    expect(f.blocked).to be false
    expect(f.home_location.name).to eq('nbg1')
    expect(f.actions.count).to eq(1)
    expect(f.actions.first.command).to eq('assign_floating_ip')
  end

  it "#create(type: ipv4, server: 1, home_location: 'fsn1')" do
    a, f = nil
    expect do
      a, f = client.floating_ips.create(type: 'ipv4', home_location: 'fsn1', server: 1)
    end.not_to raise_error
    expect(a).to be_a Hcloud::Action
    expect(a.status).to eq('running')
    expect(a.command).to eq('assign_floating_ip')
    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to eq('127.0.0.2')
    expect(f.blocked).to be false
    expect(f.home_location.name).to eq('fsn1')
  end

  it '#create(type: ipv4)' do
    a, f = nil
    expect do
      a, f = client.floating_ips.create(type: 'ipv4')
    end.not_to raise_error
    expect(a).to be nil
    expect(f).to be_a Hcloud::FloatingIP
    expect(f.ip).to eq('127.0.0.2')
    expect(f.blocked).to be false
    expect(f.home_location.name).to eq('nbg1')
  end

  it "#update(description: 'moo')" do
    expect(client.floating_ips.find(1).description).to be nil
    expect { client.floating_ips.find(1).update(description: 'moo') }.not_to raise_error
    expect(client.floating_ips.find(1).description).to eq('moo')
  end

  it '#assign(server: 999)' do
    expect(client.floating_ips.find(3).server).to be nil
    expect(client.floating_ips.find(3).assign(server: 999)).to be_a Hcloud::Action
    expect(client.floating_ips.find(3).server).to eq(999)
  end

  it '#unassign()' do
    expect(client.floating_ips.find(3).server).to eq(999)
    expect(client.floating_ips.find(3).unassign).to be_a Hcloud::Action
    expect(client.floating_ips.find(3).server).to be nil
  end

  it '#change_dns_ptr' do
    expect(client.floating_ips.first).to be_a Hcloud::FloatingIP
    expect(client.floating_ips.first.dns_ptr.count).to eq(1)
    expect(client.floating_ips.first.dns_ptr[0]['ip']).to eq('127.0.0.1')
    expect(client.floating_ips.first.dns_ptr[0]['dns_ptr']).to eq('static.1.0.0.127.clients.your-server.de')

    expect(client.floating_ips.first.change_dns_ptr(ip: '127.0.0.1', dns_ptr: 'moo')).to be_a Hcloud::Action

    expect(client.floating_ips.first.dns_ptr.count).to eq(1)
    expect(client.floating_ips.first.dns_ptr[0]['ip']).to eq('127.0.0.1')
    expect(client.floating_ips.first.dns_ptr[0]['dns_ptr']).to eq('moo')
  end

  it '#destroy()' do
    expect(client.floating_ips.count).to eq(4)
    expect { client.floating_ips.find(595).destroy }.not_to raise_error
    expect(client.floating_ips.count).to eq(3)
  end
end
