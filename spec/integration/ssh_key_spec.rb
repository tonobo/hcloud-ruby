# frozen_string_literal: true

require 'spec_helper'

REAL_KEY = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh8GH'\
  'JkJRgf3wuuUUQYG3UfqtVK56+FEXAOFaNZ659C m@x.com'
REAL_KEY_2 = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh8GH'\
  'JkJRgf3wuuUUQYG3UfqtVK56+FEXAOFaNZ659D m@x.com'

describe 'SSHKey', :integration do
  let(:key_name) { resource_name('key') }

  it 'fetch ssh_keys' do
    expect(client.ssh_keys.count).to be_a Integer
  end

  it 'create new ssh_key, handle missing name' do
    expect { client.ssh_keys.create(name: nil, public_key: 'ssh-rsa') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key, handle missing public_key' do
    expect { client.ssh_keys.create(name: key_name, public_key: nil) }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key, handle invalid public_key' do
    expect { client.ssh_keys.create(name: key_name, public_key: 'not-ssh') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it 'create new ssh_key' do
    key = client.ssh_keys.create(name: key_name, public_key: REAL_KEY, labels: { 'source' => 'test' })
    expect(key).to be_a Hcloud::SSHKey
    expect(key.id).to be_a Integer
    expect(key.name).to eq(key_name)
    expect(key.fingerprint.split(':').count).to eq(16)
    expect(key.public_key).to eq(REAL_KEY)
    expect(key.labels).to eq({ 'source' => 'test' })
  end

  it 'create new ssh_key, uniq name' do
    expect { client.ssh_keys.create(name: key_name, public_key: REAL_KEY_2) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'create new ssh_key, uniq public key' do
    expect { client.ssh_keys.create(name: 'foo', public_key: REAL_KEY) }.to(
      raise_error(Hcloud::Error::UniquenessError)
    )
  end

  it 'fetch ssh_keys' do
    expect(client.ssh_keys.count).to be_an(Integer).and be > 0
  end

  it '#[] -> find by id' do
    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys.first.id
    expect(id).to be_a Integer
    expect(client.ssh_keys[id]).to be_a Hcloud::SSHKey
    expect(client.ssh_keys[id].name).to be_a String
    expect(client.ssh_keys[id].public_key).to be_a String
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
    expect(client.ssh_keys.find(id).name).to be_a String
    expect(client.ssh_keys.find(id).public_key).to be_a String
    expect(client.ssh_keys.find(id).fingerprint.split(':').count).to eq(16)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.ssh_keys.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.ssh_keys[key_name]).to be_a Hcloud::SSHKey
    expect(client.ssh_keys[key_name].name).to eq(key_name)
    expect(client.ssh_keys[key_name].public_key).to eq(REAL_KEY)
    expect(client.ssh_keys[key_name].fingerprint.split(':').count).to eq(16)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.ssh_keys[nonexistent_name]).to be nil
  end

  it '#update' do
    new_name = resource_name('key-new')

    expect(client.ssh_keys.first).to be_a Hcloud::SSHKey
    id = client.ssh_keys[key_name].id
    expect(id).to be_a Integer
    expect(client.ssh_keys.find(id).name).to eq(key_name)
    updated = client.ssh_keys.find(id).update(
      name: new_name,
      labels: { 'source' => 'unittest' }
    )
    expect(updated.name).to eq(new_name)
    expect(updated.labels['source']).to eq('unittest')

    expect(client.ssh_keys.find(id).name).to eq(new_name)
    expect(client.ssh_keys.find(id).labels['source']).to eq('unittest')
  end

  it '#where -> find by label_selector' do
    ssh_keys = client.ssh_keys.where(label_selector: 'source=unittest').to_a
    expect(ssh_keys.length).to eq(1)
    expect(ssh_keys.first.labels).to include('source' => 'unittest')
  end

  it '#destroy' do
    to_delete = client.ssh_keys[resource_name('key-new')]
    expect(to_delete).to be_a Hcloud::SSHKey
    expect(client.ssh_keys.find(to_delete.id).destroy).to be_a Hcloud::SSHKey
    expect(client.ssh_keys[to_delete.id]).to be nil
  end
end
