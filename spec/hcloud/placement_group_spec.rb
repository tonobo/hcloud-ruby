# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'

describe Hcloud::PlacementGroup, doubles: :placement_group do
  let :placement_groups do
    Array.new(Faker::Number.within(range: 20..150)).map { new_placement_group }
  end

  let(:placement_group) { placement_groups.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector type]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class

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
      params = {
        name: 'moo',
        type: 'spread',
        labels: { 'key' => 'value' }
      }
      expectation = stub_create(:placement_group, params)

      key = client.placement_groups.create(**params)
      expect(expectation.times_called).to eq(1)

      expect(key).to be_a described_class
      expect(key.id).to be_a Integer
      expect(key.name).to eq('moo')
      expect(key.type).to eq('spread')
      expect(key.servers).to eq([])
      expect(key.created).to be_a Time
      expect(key.labels).to eq(params[:labels])
    end

    it 'validates uniq name' do
      stub_error(:placement_groups, :post, 'uniqueness_error', 409)

      expect { client.placement_groups.create(name: 'moo', type: 'spread') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
