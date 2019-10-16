# frozen_string_literal: true

require 'spec_helper'

describe 'Location' do
  before(:each) do
    Hcloud::Client.connection = Hcloud::Client.new(token: 'secure')
  end
  after(:each) do
    Hcloud::Client.connection = nil
  end
  let :client do
  end
  it 'fetchs locations' do
    expect(Hcloud::Location.count).to eq(2)
  end

  it '#[] -> find by id' do
    expect(Hcloud::Location[1].id).to eq(1)
  end

  it '#[] -> find by id, handle nonexistent' do
    expect(Hcloud::Location[3]).to be nil
  end

  it '#find -> find by id' do
    expect(Hcloud::Location.find(1).id).to eq(1)
  end

  it '#find -> find by id, handle nonexistent' do
    expect { Hcloud::Location.find(3).id }.to raise_error(Hcloud::Error::NotFound)
  end

  it '#[] -> filter by name' do
    expect(Hcloud::Location['fsn1'].name).to eq('fsn1')
  end

  it '#[] -> filter by name, handle nonexistent' do
    expect(Hcloud::Location['mooo']).to be nil
  end
end
