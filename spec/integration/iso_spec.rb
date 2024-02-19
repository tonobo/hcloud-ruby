# frozen_string_literal: true

require 'spec_helper'

describe 'ISO', :integration do
  it 'fetchs isos' do
    expect(client.isos.count).to be_an(Integer).and be > 0
  end

  it '#[] -> find by id' do
    id = client.isos.first.id
    expect(id).to be_an Integer
    expect(client.isos[id]).to be_a Hcloud::Iso
    expect(client.isos[id].id).to eq(id)
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.isos[-1]).to be nil
  end

  it '#find -> find by id' do
    id = client.isos.first.id
    expect(id).to be_a Integer
    expect(client.isos.find(id)).to be_a Hcloud::Iso
    expect(client.isos.find(id).id).to eq(id)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.isos.find(-1).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    name = client.isos.first.name
    expect(name).to be_a String
    expect(client.isos[name]).to be_a Hcloud::Iso
    expect(client.isos[name].name).to eq(name)
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.isos[nonexistent_name]).to be nil
  end

  it '#find_by -> filter by name' do
    name = client.isos.first.name
    expect(name).to be_a String
    expect(client.isos.find_by(name: name)).to be_a Hcloud::Iso
    expect(client.isos.find_by(name: name).name).to eq(name)
  end

  it '#find_by -> filter by name, handle nonexistent' do
    expect(client.isos.find_by(name: nonexistent_name)).to be nil
  end
end
