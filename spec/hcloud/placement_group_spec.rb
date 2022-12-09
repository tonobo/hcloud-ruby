# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels'

describe Hcloud::PlacementGroup, doubles: :placement_group do
  include_context 'test doubles'

  let :placement_groups do
    Array.new(Faker::Number.within(range: 20..150)).map { new_placement_group }
  end

  let(:placement_group) { placement_groups.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels', described_class, { name: 'moo', type: 'spread' }

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
      stub_error(:placement_groups, :post, 'uniqueness_error', 409)

      expect { client.placement_groups.create(name: 'moo', type: 'spread') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
