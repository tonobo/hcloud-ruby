require 'spec_helper'

describe 'ISO' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetchs isos' do
    expect(client.isos.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.isos[26].id).to eq(26)
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.isos[3]).to be nil
  end

  it '#find -> find by id' do
    expect(client.isos.find(26).id).to eq(26)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.isos.find(3).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.isos['virtio-win-0.1.141.iso'].name).to eq('virtio-win-0.1.141.iso')
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.isos['mooo']).to be nil
  end
end
