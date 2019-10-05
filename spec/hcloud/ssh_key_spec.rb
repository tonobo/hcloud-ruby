# frozen_string_literal: true

require 'spec_helper'

REAL_KEY = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh8GH'\
  'JkJRgf3wuuUUQYG3UfqtVK56+FEXAOFaNZ659C m@x.com'

describe 'SSHKey' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end
  it 'fetch ssh_keys' do
    expect(client.ssh_keys.count).to eq(0)
  end

  it 'create new ssh_key, handle missing name' do
    expect { client.ssh_keys.create(name: nil, public_key: 'ssh-rsa') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key, handle missing public_key' do
    expect { client.ssh_keys.create(name: 'moo', public_key: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key, handle invalid public_key' do
    expect { client.ssh_keys.create(name: 'moo', public_key: 'not-ssh') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key' do
    key = client.ssh_keys.create(name: 'moo', public_key: REAL_KEY)
    expect(key).to be_a Hcloud::SSHKey
    expect(key.id).to be_a Integer
    expect(key.name).to eq('moo')
    expect(key.fingerprint.split(':').count).to eq(16)
    expect(key.public_key).to eq(REAL_KEY)
  end

  it 'create new ssh_key, uniq name' do
    expect { client.ssh_keys.create(name: 'moo', public_key: 'ssh-rsa') }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'create new ssh_key, uniq public key' do
    expect { client.ssh_keys.create(name: 'foo', public_key: REAL_KEY) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'fetch ssh_keys' do
    expect(client.ssh_keys.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys.first.id
    expect(id).to be_a Integer
    expect(client.ssh_keys[id]).to be_a Hcloud::SSHKey
    expect(client.ssh_keys[id].name).to eq('moo')
    expect(client.ssh_keys[id].public_key).to eq(REAL_KEY)
    expect(client.ssh_keys[id].fingerprint.split(':').count).to eq(16)
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.ssh_keys[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys.first.id
    expect(id).to be_a Integer
    expect(client.ssh_keys.find(id)).to be_a Hcloud::SSHKey
    expect(client.ssh_keys.find(id).name).to eq('moo')
    expect(client.ssh_keys.find(id).public_key).to eq(REAL_KEY)
    expect(client.ssh_keys.find(id).fingerprint.split(':').count).to eq(16)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.ssh_keys.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.ssh_keys['moo']).to be_a Hcloud::SSHKey
    expect(client.ssh_keys['moo'].name).to eq('moo')
    expect(client.ssh_keys['moo'].public_key).to eq(REAL_KEY)
    expect(client.ssh_keys['moo'].fingerprint.split(':').count).to eq(16)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.ssh_keys['mooo']).to be nil
  end

  it '#update' do
    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys.first.id
    expect(id).to be_a Integer
    expect(client.ssh_keys.find(id).name).to eq('moo')
    expect(client.ssh_keys.find(id).update(name: 'hui').name).to eq('hui')
    expect(client.ssh_keys.find(id).name).to eq('hui')
  end

  it '#destroy' do
    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys.first.id
    expect(id).to be_a Integer
    expect(client.ssh_keys.find(id).destroy).to be true
    expect(client.ssh_keys[id]).to be nil
  end
end
