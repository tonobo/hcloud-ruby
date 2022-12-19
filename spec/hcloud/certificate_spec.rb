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

describe Hcloud::Certificate, doubles: :certificate do
  include_context 'test doubles'

  let :certificates do
    Array.new(Faker::Number.within(range: 20..150)).map { new_certificate }
  end

  let(:certificate) { certificates.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector type]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_action_fetch', described_class

  context '#create' do
    it 'handle missing name' do
      params = {
        name: nil,
        type: :managed,
        domain_names: ['example.com']
      }
      expect { client.certificates.create(**params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles missing domains for type "managed"' do
      params = {
        name: 'moo',
        type: :managed,
        domain_names: []
      }
      expect { client.certificates.create(**params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles missing certificate for type "uploaded"' do
      params = {
        name: 'moo',
        type: :uploaded,
        certificate: nil,
        private_key: 'secret'
      }
      expect { client.certificates.create(**params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles missing private_key for type "uploaded"' do
      params = {
        name: 'moo',
        type: :uploaded,
        certificate: 'cert',
        private_key: nil
      }
      expect { client.certificates.create(**params) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    context 'works' do
      it 'with managed certificate' do
        params = { name: 'moo', type: 'managed', domain_names: ['example.com'] }

        expectation = stub_create(
          :certificate,
          params,
          action: new_action(:running, command: 'create_certificate')
        )

        action, certificate = client.certificates.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(action).to be_a Hcloud::Action
        expect(certificate).to be_a described_class
        expect(certificate).to have_attributes(id: a_kind_of(Integer), name: 'moo')
      end

      it 'with uploaded certificate' do
        params = {
          name: 'moo',
          type: 'uploaded',
          certificate: 'cert',
          private_key: 'secret'
        }
        # response does not include the private key
        response_params = {
          name: params[:name],
          certificate: params[:certificate]
        }
        expectation = stub_create(
          :certificate,
          params,
          response_params: response_params,
          action: new_action(:running, command: 'create_certificate')
        )

        action, certificate = client.certificates.create(**params)
        expect(expectation.times_called).to eq(1)
        expect(action).to be_a Hcloud::Action
        expect(certificate).to be_a described_class
        expect(certificate).to have_attributes(
          id: a_kind_of(Integer),
          name: 'moo',
          certificate: 'cert'
        )
      end
    end

    it 'validates uniq name' do
      params = {
        name: 'moo',
        type: :managed,
        domain_names: ['example.com']
      }
      stub_error(:certificates, :post, 'uniqueness_error', 409)

      expect { client.certificates.create(**params) }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
