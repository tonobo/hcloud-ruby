# frozen_string_literal: true

require 'spec_helper'

describe 'Datacenter', :integration do
  let(:valid_name) { 'fsn1-dc14' }

  it 'fetchs datacenters' do
    # datacenters are Hetzner-managed, there must always be at least one
    expect(client.datacenters.count).to be_a(Integer).and be > 0
    expect(client.datacenters).to all(be_a(Hcloud::Datacenter))
  end

  it '#[] -> find by id' do
    expect(client.datacenters[client.datacenters.first.id]).to be_a Hcloud::Datacenter
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.datacenters[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.datacenters.find(client.datacenters.first.id)).to be_a Hcloud::Datacenter
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.datacenters.find(0) }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.datacenters[valid_name].name).to eq(valid_name)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.datacenters['fsn42-dc42']).to be nil
  end

  it '#find_by -> filter by name' do
    expect(client.datacenters.find_by(name: valid_name).name).to eq(valid_name)
  end

  it '#find_by -> filter by name, handle nonexistent' do
    expect(client.datacenters.find_by(name: 'fsn42-dc42')).to be nil
  end

  it '#[] -> filter by name, handle invalid format' do
    expect { client.datacenters['fsn1dc3'] }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end

  it '#find_by -> filter by name, handle invalid format' do
    expect { client.datacenters.find_by(name: 'fsn1dc3') }.to(
      raise_error(Hcloud::Error::InvalidInput)
    )
  end
end
