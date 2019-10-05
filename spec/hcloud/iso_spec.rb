# frozen_string_literal: true

require 'spec_helper'

describe 'ISO' do
  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetchs isos' do
    expect(client.isos.count).to eq(1)
  end

  it '#[] -> find by id' do
    expect(client.isos.first).to be_a Hcloud::Iso
    id = client.isos.first.id
    expect(id).to be_a Integer
    expect(client.isos[id]).to be_a Hcloud::Iso
    expect(client.isos[id].id).to eq(id)
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.isos[3]).to be nil
  end

  it '#find -> find by id' do
    expect(client.isos.first).to be_a Hcloud::Iso
    id = client.isos.first.id
    expect(id).to be_a Integer
    expect(client.isos.find(id)).to be_a Hcloud::Iso
    expect(client.isos.find(id).id).to eq(id)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.isos.find(3).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.isos.first).to be_a Hcloud::Iso
    name = client.isos.first.name
    expect(name).to be_a String
    expect(client.isos[name]).to be_a Hcloud::Iso
    expect(client.isos[name].name).to eq(name)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.isos['mooo']).to be nil
  end

  it '#find_by -> filter by name' do
    expect(client.isos.first).to be_a Hcloud::Iso
    name = client.isos.first.name
    expect(name).to be_a String
    expect(client.isos.find_by(name: name)).to be_a Hcloud::Iso
    expect(client.isos.find_by(name: name).name).to eq(name)
  end

  it '#find_by -> filter by name, handle nonexistent' do
    expect(client.isos.find_by(name: 'moo')).to be nil
  end
end
