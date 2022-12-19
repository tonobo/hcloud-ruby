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

describe Hcloud::FloatingIP, doubles: :floating_ip do
  include_context 'test doubles'

  let :floating_ips do
    Array.new(Faker::Number.within(range: 20..150)).map { new_floating_ip }
  end

  let(:floating_ip) { floating_ips.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', \
                   described_class, \
                   { name: 'new_name', description: 'new_desc' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_action_fetch', described_class

  context '#create' do
    it 'handle missing type' do
      expect { client.floating_ips.create(type: nil, home_location: 'fsn1') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing home_location and server' do
      expect do
        client.floating_ips.create(type: 'ipv4', home_location: nil, server: nil)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'works' do
      params = {
        type: 'ipv4',
        home_location: 'fsn1',
        labels: { 'key' => 'value', 'novalue' => '' }
      }
      response_params = {
        type: params[:type],
        home_location: floating_ip[:home_location],
        labels: params[:labels]
      }
      expectation = stub_create(:floating_ip, params, response_params: response_params)

      _action, key = client.floating_ips.create(**params)
      expect(expectation.times_called).to eq(1)

      expect(key).to be_a described_class
      expect(key.id).to be_a Integer
      expect(key.name).to be_a String
      expect(key.type).to eq('ipv4')
      expect(key.home_location).to be_a Hcloud::Location
      expect(key.created).to be_a Time
      expect(key.labels).to eq(params[:labels])
    end

    it 'validates uniq name' do
      pending 'Implementation of floating IP does not support name, yet'

      stub_error(:floating_ips, :post, 'uniqueness_error', 409)

      expect do
        client.floating_ips.create(name: 'moo', type: 'ipv4', home_location: 'fsn1')
      end.to raise_error(Hcloud::Error::UniquenessError)
    end
  end
end
