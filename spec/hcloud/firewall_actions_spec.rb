# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Firewall, doubles: :firewall do
  let :firewalls do
    Array.new(Faker::Number.within(range: 20..150)).map { new_firewall }
  end

  let(:firewall) { firewalls.sample }

  let :firewall_obj do
    stub_item(:firewalls, firewall)
    client.firewalls[firewall[:id]]
  end

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  def actions_resource_ids(actions)
    actions.map { |action| action.resources.map { |res| res['id'] } }.flatten
  end

  context '#apply_to_resources' do
    it 'handles missing apply_to' do
      expect { firewall_obj.apply_to_resources(apply_to: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles firewall_already_applied error' do
      stub_error(
        "firewalls/#{firewall[:id]}/actions/apply_to_resources",
        :post,
        :firewall_already_applied,
        422
      )

      apply_to = [{ 'server' => { 'id' => 42 }, 'type' => 'server' }]
      expect do
        firewall_obj.apply_to_resources(apply_to: apply_to)
      end.to raise_error Hcloud::Error::ServerError
    end

    it 'works' do
      apply_to = [
        { 'server' => { 'id' => 42 }, 'type' => 'server' },
        { 'server' => { 'id' => 1 }, 'type' => 'server' }
      ]
      stub_action(:firewalls, firewall[:id], :apply_to_resources) do |_req, _info|
        {
          actions: [
            build_action_resp(
              :apply_firewall, :running,
              resources: [{ id: 42, type: 'server' }, { id: firewall[:id], type: 'firewall' }]
            ),
            build_action_resp(
              :apply_firewall, :running,
              resources: [{ id: 1, type: 'server' }, { id: firewall[:id], type: 'firewall' }]
            )
          ]
        }
      end

      actions = firewall_obj.apply_to_resources(apply_to: apply_to)
      expect(actions.length).to eq(2)
      expect(actions[0]).to be_a(Hcloud::Action)
      expect(actions_resource_ids(actions)).to include(1, 42, firewall[:id])
    end
  end

  context '#remove_from_resources' do
    it 'handles missing remove_from' do
      expect { firewall_obj.remove_from_resources(remove_from: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handles firewall_already_removed error' do
      stub_error(
        "firewalls/#{firewall[:id]}/actions/remove_from_resources",
        :post,
        :firewall_already_removed,
        422
      )

      expect do
        firewall_obj.remove_from_resources(
          remove_from: [{ 'server' => { 'id' => 42 }, 'type' => 'server' }]
        )
      end.to raise_error Hcloud::Error::ServerError
    end

    it 'works' do
      remove_from = [
        { 'server' => { 'id' => 42 }, 'type' => 'server' },
        { 'server' => { 'id' => 1 }, 'type' => 'server' }
      ]
      stub_action(:firewalls, firewall[:id], :remove_from_resources) do |_req, _info|
        {
          actions: [
            build_action_resp(
              :remove_firewall, :running,
              resources: [{ id: 42, type: 'server' }, { id: firewall[:id], type: 'firewall' }]
            ),
            build_action_resp(
              :remove_firewall, :running,
              resources: [{ id: 1, type: 'server' }, { id: firewall[:id], type: 'firewall' }]
            )
          ]
        }
      end

      actions = firewall_obj.remove_from_resources(remove_from: remove_from)
      expect(actions.length).to eq(2)
      expect(actions[0]).to be_a(Hcloud::Action)
      expect(actions_resource_ids(actions)).to include(1, 42, firewall[:id])
    end
  end

  context '#set_rules' do
    it 'accepts nil to remove rules' do
      expectation = stub("firewalls/#{firewall[:id]}/actions/set_rules", :post) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'rules' => [] }))

        {
          body: {
            actions: [
              build_action_resp(
                :set_firewall_rules, :running,
                resources: [{ id: firewall[:id], type: 'firewall' }]
              )
            ]
          },
          code: 201
        }
      end

      firewall_obj.set_rules(rules: nil)
      expect(expectation.times_called).to eq(1)
    end

    it 'works' do
      rules = [
        { protocol: 'tcp', port: 80, direction: 'in', source_ips: '0.0.0.0/0' }
      ]
      expectation = stub_action(:firewalls, firewall[:id], :set_rules) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'rules' => rules }.deep_stringify_keys))

        {
          actions: [
            build_action_resp(
              :set_firewall_rules, :running,
              resources: [{ id: firewall[:id], type: 'firewall' }]
            )
          ]
        }
      end

      actions = firewall_obj.set_rules(rules: rules)
      expect(actions.length).to eq(1)
      expect(actions[0]).to be_a(Hcloud::Action)
      expect(actions_resource_ids(actions)).to eq([firewall[:id]])
      expect(expectation.times_called).to eq(1)
    end
  end
end
