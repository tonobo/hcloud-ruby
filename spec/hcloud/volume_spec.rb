# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'
require 'support/it_supports_action_fetch'

describe Hcloud::Volume, doubles: :volume do
  include_context 'test doubles'

  let :volumes do
    Array.new(Faker::Number.within(range: 20..150)).map { new_volume }
  end

  let(:volume) { volumes.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_action_fetch', described_class

  context '#create' do
    it 'handle missing name' do
      expect { client.volumes.create(name: nil, size: 10, location: 'fsn1') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing size' do
      expect { client.volumes.create(name: 'moo', size: nil, location: 'fsn1') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle too small size' do
      expect { client.volumes.create(name: 'moo', size: 5, location: 'fsn1') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing location and server' do
      expect { client.volumes.create(name: 'moo', size: 10, location: nil, server: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    context 'works' do
      it 'with required parameters' do
        params = { name: 'moo', size: 10, location: 'fsn1' }
        response_params = {
          name: params[:name],
          size: params[:size],
          location: new_location
        }
        expectation = stub_create(
          :volume,
          params,
          response_params: response_params,
          action: new_action(:running, command: 'create_volume'),
          next_actions: []
        )

        _action, volume, _next_actions = client.volumes.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(volume).to be_a described_class
        expect(volume.id).to be_a Integer
        expect(volume.created).to be_a Time
        expect(volume.name).to eq('moo')
        expect(volume.size).to eq(10)
      end

      it 'with all parameters' do
        params = {
          name: 'moo',
          size: 10,
          location: 'fsn1',
          format: 'ext4',
          automount: false,
          labels: { 'key' => 'value' }
        }
        response_params = {
          name: params[:name],
          size: params[:size],
          location: new_location,
          linux_device: '/foo/bar',
          labels: params[:labels]
        }

        expectation = stub_create(
          :volume,
          params,
          response_params: response_params,
          action: new_action(:running, command: 'create_volume'),
          next_actions: []
        )

        _action, volume, _next_actions = client.volumes.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(volume).to be_a described_class
        expect(volume.id).to be_a Integer
        expect(volume.created).to be_a Time
        expect(volume.name).to eq('moo')
        expect(volume.size).to eq(10)
        expect(volume.linux_device).to eq('/foo/bar')
        expect(volume.labels).to eq(params[:labels])
      end
    end

    it 'validates uniq name' do
      stub_error(:volumes, :post, 'uniqueness_error', 409)

      expect { client.volumes.create(name: 'moo', size: 10, location: 'fsn1') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
