# frozen_string_literal: true

require 'spec_helper'

describe 'Location', :integration do
  it 'fetchs locations' do
    expect(client.locations.count).to be_a Integer
  end

  it '#[] -> find by id' do
    expect(client.locations[client.locations.first.id]).to be_a Hcloud::Location
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(client.locations[0]).to be nil
  end

  it '#find -> find by id' do
    expect(client.locations.find(client.locations.first.id)).to be_a Hcloud::Location
  end

  it '#find -> find by id, handle nonexistent' do
    expect { client.locations.find(0).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(client.locations['fsn1'].name).to eq('fsn1')
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(client.locations['mooo']).to be nil
  end
end
