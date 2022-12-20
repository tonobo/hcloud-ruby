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

describe Hcloud::PrimaryIP, doubles: :primary_ip do
  include_context 'test doubles'

  let :primary_ips do
    Array.new(Faker::Number.within(range: 20..150)).map { new_primary_ip }
  end

  let(:primary_ip) { primary_ips.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name label_selector ip]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', \
                   described_class, \
                   { name: 'new_name', auto_delete: true }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class

  context '#create' do
    context 'with missing parameter' do
      let :params do
        {
          name: 'moo',
          type: 'ipv4',
          assignee_type: 'server',
          assignee_id: 42
        }
      end

      it 'handles missing name' do
        params[:name] = nil
        expect do
          client.primary_ips.create(**params)
        end.to raise_error(Hcloud::Error::InvalidInput)
      end

      it 'handles missing type' do
        params[:type] = nil
        expect do
          client.primary_ips.create(**params)
        end.to raise_error(Hcloud::Error::InvalidInput)
      end

      it 'handles missing assignee_type' do
        params[:assignee_type] = nil
        expect do
          client.primary_ips.create(**params)
        end.to raise_error(Hcloud::Error::InvalidInput)
      end

      it 'handles missing assignee_id and datacenter' do
        params[:assignee_id] = nil
        params[:datacenter] = nil

        expect do
          client.primary_ips.create(**params)
        end.to raise_error(Hcloud::Error::InvalidInput)
      end
    end

    context 'without assignee_type specified' do
      it 'defaults to "server"' do
        params = { name: 'moo', type: 'ipv4', assignee_id: 42 }
        stub = stub_create(:primary_ip, params)

        _action, primary_ip = client.primary_ips.create(**params)
        expect(stub.times_called).to eq(1)
        expect(primary_ip).to have_attributes(assignee_type: 'server')
      end
    end

    context 'works' do
      it 'with required parameters' do
        params = {
          name: 'moo',
          type: 'ipv4',
          assignee_id: 42
        }
        stub = stub_create(
          :primary_ip,
          params,
          action: new_action(:running, command: 'create_primary_ip')
        )

        action, ip = client.primary_ips.create(**params)
        expect(stub.times_called).to eq(1)

        expect(action).to be_a(Hcloud::Action)

        expect(ip).to be_a described_class
        expect(ip).to have_attributes(
          id: a_kind_of(Integer),
          name: 'moo',
          type: 'ipv4',
          assignee_id: 42
        )
      end

      it 'with datacenter' do
        params = {
          name: 'moo',
          type: 'ipv4',
          datacenter: 'fsn1-dc14'
        }
        response_params = params.deep_dup
        response_params[:datacenter] = new_datacenter(name: params[:datacenter])
        stub = stub_create(
          :primary_ip,
          params,
          response_params: response_params,
          action: new_action(:running, command: 'create_primary_ip')
        )

        action, ip = client.primary_ips.create(**params)
        expect(stub.times_called).to eq(1)

        expect(action).to be_a Hcloud::Action

        expect(ip).to be_a described_class
        expect(ip).to have_attributes(datacenter: a_kind_of(Hcloud::Datacenter))
      end

      it 'with all parameters' do
        params = {
          name: 'moo',
          type: 'ipv4',
          assignee_type: 'server',
          assignee_id: 42,
          auto_delete: true,
          labels: { 'key' => 'value' }
        }
        stub = stub_create(
          :primary_ip,
          params,
          action: new_action(:running, command: 'create_primary_ip')
        )

        action, ip = client.primary_ips.create(**params)
        expect(stub.times_called).to eq(1)

        expect(action).to be_a Hcloud::Action

        expect(ip).to be_a described_class
        expect(ip).to have_attributes(**params.merge(id: a_kind_of(Integer)))
      end
    end

    it 'validates uniq name' do
      stub_error(:primary_ips, :post, 'uniqueness_error', 409)

      expect do
        client.primary_ips.create(name: 'moo', type: 'ipv4', assignee_id: 42)
      end.to raise_error(Hcloud::Error::UniquenessError)
    end
  end
end
