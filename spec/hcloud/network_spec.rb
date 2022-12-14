# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'

describe Hcloud::Network, doubles: :network do
  include_context 'test doubles'

  let :networks do
    Array.new(Faker::Number.within(range: 20..150)).map { new_network }
  end

  let(:network) { networks.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class

  context '#create' do
    it 'handle missing name' do
      expect { client.networks.create(name: nil, ip_range: '10.0.0.0/16') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing ip_range' do
      expect { client.networks.create(name: 'moo', ip_range: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    context 'works' do
      it 'with minimum required parameters' do
        params = { name: 'moo', ip_range: '10.0.0.0/16' }
        stub_create(:network, params)

        key = client.networks.create(**params)
        expect(key).to be_a described_class
        expect(key.id).to be_a Integer
        expect(key.name).to eq('moo')
        expect(key.ip_range).to eq('10.0.0.0/16')
        expect(key.created).to be_a Time
        expect(key.protection[:delete]).to be_in([true, false])
      end

      it 'with all parameters' do
        params = {
          name: 'moo',
          ip_range: '10.0.0.0/16',
          routes: [{
            destination: '10.100.1.0/24',
            gateway: '10.0.1.1'
          }],
          subnets: [{
            ip_range: '10.0.1.0/24',
            network_zone: 'eu-central',
            type: 'cloud'
          }],
          labels: { 'key' => 'value' }
        }
        expectation = stub_create(:network, params)

        key = client.networks.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(key).to be_a described_class
        expect(key.id).to be_a Integer
        expect(key.name).to eq('moo')
        expect(key.ip_range).to eq('10.0.0.0/16')
        expect(key.created).to be_a Time
        expect(key.protection[:delete]).to be_in([true, false])
        expect(key.routes).to eq(params[:routes].map(&:deep_stringify_keys))
        expect(key.subnets).to eq(params[:subnets].map(&:deep_stringify_keys))
        expect(key.labels).to eq(params[:labels])
      end
    end

    it 'validates uniq name' do
      stub_error(:networks, :post, 'uniqueness_error', 409)

      expect { client.networks.create(name: 'moo', ip_range: '10.0.0.0/16') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
