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

describe Hcloud::Firewall, doubles: :firewall do
  let :firewalls do
    Array.new(Faker::Number.within(range: 20..150)).map { new_firewall }
  end

  let(:firewall) { firewalls.sample }

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
      expect { client.firewalls.create(name: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    context 'works' do
      it 'with required parameters' do
        params = { name: 'moo' }
        expectation = stub_create(:firewall, params, actions: [])

        actions, firewall = client.firewalls.create(**params)
        expect(expectation.times_called).to eq(1)

        expect(actions).to all be_a Hcloud::Action

        expect(firewall).to be_a described_class
        expect(firewall.id).to be_a Integer
        expect(firewall.created).to be_a Time
        expect(firewall.name).to eq('moo')
      end

      it 'with all parameters' do
        params = {
          name: 'moo',
          apply_to: [{
            server: { id: 42 },
            type: 'server'
          }],
          rules: [{
            protocol: 'tcp',
            port: 80,
            direction: 'in',
            source_ips: ['192.0.2.0/24', '2001:db8::/32']
          }],
          labels: { 'key' => 'value' }
        }
        response_params = {
          name: params[:name],
          applied_to: params[:apply_to],
          rules: params[:rules],
          labels: params[:labels]
        }
        stub_create(
          :firewall,
          params,
          response_params: response_params,
          actions:
          [
            new_action(:running, command: 'apply_firewall'),
            new_action(:running, command: 'set_firewall_rules')
          ]
        )

        actions, firewall = client.firewalls.create(**params)
        expect(actions).to all be_a Hcloud::Action

        expect(firewall).to be_a described_class
        expect(firewall.id).to be_a Integer
        expect(firewall.created).to be_a Time
        expect(firewall.name).to eq('moo')
        expect(firewall.rules).to eq(params[:rules].map(&:deep_stringify_keys))
        expect(firewall.applied_to).to eq(params[:apply_to].map(&:deep_stringify_keys))
        expect(firewall.labels).to eq(params[:labels])
      end

      it 'with IPv6 ::/0' do
        # IPv6 global address ::/0 can cause some problems, because if parsed from JSON with
        # the wrong parser settings it gets interpreted as a Ruby symbol. This results
        # in the deletion of the first : character.
        params = {
          name: 'moo',
          rules: [{
            protocol: 'tcp',
            port: 443,
            direction: 'in',
            source_ips: ['::/0']
          }]
        }
        stub_create(
          :firewall,
          params,
          actions: [new_action(:running, command: 'set_firewall_rules')]
        )

        _actions, firewall = client.firewalls.create(**params)
        expect(firewall.rules[0][:source_ips]).to eq(['::/0'])
      end
    end

    it 'validates uniq name' do
      stub_error(:firewalls, :post, 'uniqueness_error', 409)

      expect { client.firewalls.create(name: 'moo') }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
