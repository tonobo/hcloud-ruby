require 'spec_helper'

describe 'ServerType' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetch server_types' do
    expect(client.server_types.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.server_types.first).to be_a Hcloud::ServerType
    id = client.server_types.first.id
    expect(id).to be_a Integer
    expect(client.server_types[id]).to be_a Hcloud::ServerType
    expect(client.server_types[id].name).to be_a String
    expect(client.server_types[id].description).to be_a String
    expect(client.server_types[id].cores).to be_a Integer
    expect(client.server_types[id].memory).to be_a Float
    expect(client.server_types[id].prices).to be_a Array
    expect(client.server_types[id].storage_type).to be_a String
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.ssh_keys[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.server_types.first).to be_a Hcloud::ServerType
    id = client.server_types.first.id
    expect(id).to be_a Integer
    expect(client.server_types.find(id)).to be_a Hcloud::ServerType
    expect(client.server_types.find(id).name).to be_a String
    expect(client.server_types.find(id).description).to be_a String
    expect(client.server_types.find(id).cores).to be_a Integer
    expect(client.server_types.find(id).memory).to be_a Float
    expect(client.server_types.find(id).prices).to be_a Array
    expect(client.server_types.find(id).storage_type).to be_a String
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.ssh_keys.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.server_types['cx11']).to be_a Hcloud::ServerType
    expect(client.server_types['cx11'].name).to be_a String
    expect(client.server_types['cx11'].description).to be_a String
    expect(client.server_types['cx11'].cores).to be_a Integer
    expect(client.server_types['cx11'].memory).to be_a Float
    expect(client.server_types['cx11'].prices).to be_a Array
    expect(client.server_types['cx11'].storage_type).to be_a String
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.ssh_keys['mooo']).to be nil
  end
end
