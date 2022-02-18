# frozen_string_literal: true

require 'spec_helper'
require 'it_supports_find_by_id_and_name'

describe Hcloud::PlacementGroup, doubles: :placement_group do
  include_context 'test doubles'

  let :placement_groups do
    Array.new(Faker::Number.within(range: 20..150)).map { new_placement_group }
  end

  let(:placement_group) { placement_groups.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_find_by_id_and_name', described_class

  context '#create' do
    it 'handle missing name' do
      expect { client.placement_groups.create(name: nil, type: 'spread') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing type' do
      expect { client.placement_groups.create(name: 'moo', type: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle invalid type' do
      expect { client.placement_groups.create(name: 'moo', type: 'not-spread') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'works' do
      params = { name: 'moo', type: 'spread' }
      stub_create(:placement_group, params)

      key = client.placement_groups.create(**params)
      expect(key).to be_a described_class
      expect(key.id).to be_a Integer
      expect(key.name).to eq('moo')
      expect(key.type).to eq('spread')
      expect(key.servers).to eq([])
      expect(key.created).to be_a Time
    end

    it 'validates uniq name' do
      expect { client.placement_groups.create(name: 'moo', type: 'spread') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end

  it 'fetch placement_groups' do
    stub_collection(:placement_groups, placement_groups)
    expect(client.placement_groups.count).to be_positive
  end

  it '#update' do
    new_name = 'hello_pg'
    id = placement_group[:id]
    stub_update(:placement_groups, { id: id, name: new_name })

    expect(client.placement_groups.find(id).update(name: new_name).name).to eq(new_name)
    expect(client.placement_groups.find(id).name).to eq(new_name)
  end

  it '#destroy' do
    id = placement_group[:id]
    stub_delete(:placement_groups, id)

    expect(client.placement_groups.find(id).destroy).to be_a described_class
    expect(client.placement_groups[id]).to be nil
  end
end
