# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::LoadBalancer, doubles: :load_balancer do
  include_context 'test doubles'

  let :load_balancers do
    Array.new(Faker::Number.within(range: 5..30)).map { new_load_balancer }
  end

  let(:load_balancer) { load_balancers.sample }

  let :load_balancer_obj do
    stub_item(:load_balancers, load_balancer)
    client.load_balancers[load_balancer[:id]]
  end

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  def test_action(action_name, command_name = nil, params: nil)
    command_name = action_name if command_name.nil?

    expectation = stub_action(:load_balancers, load_balancer[:id], action_name) do |req, _info|
      unless params.nil?
        expect(req).to have_body_params(a_hash_including(params.deep_stringify_keys))
      end

      {
        action: build_action_resp(
          command_name, :running,
          resources: [{ id: load_balancer[:id], type: 'load_balancer' }]
        )
      }
    end

    action = if params.nil?
               load_balancer_obj.send(action_name)
             else
               load_balancer_obj.send(action_name, **params)
             end

    expect(expectation.times_called).to eq(1)

    expect(action).to be_a(Hcloud::Action)
    expect(action.command).to eq(command_name.to_s)
  end

  it '#disable_public_interface' do
    test_action(:disable_public_interface)
  end

  it '#enable_public_interface' do
    test_action(:enable_public_interface)
  end

  it '#change_protection' do
    test_action(:change_protection, params: { delete: true })
  end

  context '#attach_to_network' do
    it 'handles missing network' do
      expect do
        load_balancer_obj.attach_to_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:attach_to_network, params: { network: 1, ip: '10.0.0.10' })
    end
  end

  context '#detach_from_network' do
    it 'handles missing network' do
      expect do
        load_balancer_obj.detach_from_network(network: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:detach_from_network, params: { network: 1 })
    end
  end

  context '#change_type' do
    it 'handles missing load_balancer_type' do
      expect do
        load_balancer_obj.change_type(load_balancer_type: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:change_type, :change_load_balancer_type, params: { load_balancer_type: 'lb31' })
    end
  end

  context '#change_algorithm' do
    it 'handles missing algorithm' do
      expect do
        load_balancer_obj.change_algorithm(type: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:change_algorithm, params: { type: 'least_connections' })
    end
  end

  context '#change_dns_ptr' do
    it 'handles missing dns_ptr' do
      expect do
        load_balancer_obj.change_dns_ptr(ip: '2001:db8::1', dns_ptr: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing ip' do
      expect do
        load_balancer_obj.change_dns_ptr(ip: nil, dns_ptr: 'example.com')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:change_dns_ptr, params: { ip: '2001:db8::1', dns_ptr: 'example.com' })
    end
  end

  context '#add_service' do
    context 'handles missing' do
      def test_missing(attribute)
        params = new_load_balancer_service
        params[attribute] = nil
        expect do
          load_balancer_obj.add_service(**params)
        end.to raise_error Hcloud::Error::InvalidInput
      end

      it 'protocol' do
        test_missing(:protocol)
      end

      it 'listen_port' do
        test_missing(:listen_port)
      end

      it 'destination_port' do
        test_missing(:destination_port)
      end

      it 'health_check' do
        test_missing(:health_check)
      end

      it 'proxyprotocol' do
        test_missing(:proxyprotocol)
      end
    end

    it 'works' do
      test_action(:add_service, params: new_load_balancer_service)
    end
  end

  context '#update_service' do
    context 'handles missing' do
      def test_missing(attribute)
        params = new_load_balancer_service
        params[attribute] = nil
        expect do
          load_balancer_obj.update_service(**params)
        end.to raise_error Hcloud::Error::InvalidInput
      end

      it 'protocol' do
        test_missing(:protocol)
      end

      it 'listen_port' do
        test_missing(:listen_port)
      end

      it 'destination_port' do
        test_missing(:destination_port)
      end

      it 'health_check' do
        test_missing(:health_check)
      end

      it 'proxyprotocol' do
        test_missing(:proxyprotocol)
      end
    end

    it 'works' do
      test_action(:update_service, params: new_load_balancer_service)
    end
  end

  context '#delete_service' do
    it 'handles missing port' do
      expect do
        load_balancer_obj.delete_service(listen_port: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'works' do
      test_action(:delete_service, params: { listen_port: 80 })
    end
  end

  context '#add_target' do
    it 'handles missing type' do
      expect do
        load_balancer_obj.add_target(type: nil, ip: '10.0.0.1')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing server' do
      expect do
        load_balancer_obj.add_target(type: 'server', server: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing ip' do
      expect do
        load_balancer_obj.add_target(type: 'ip', ip: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing label_selector' do
      expect do
        load_balancer_obj.add_target(type: 'label_selector', label_selector: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    context 'works' do
      it 'with server target' do
        test_action(:add_target, params: { server: { id: 42 }, type: 'server' })
      end

      it 'with ip target' do
        test_action(:add_target, params: { ip: '10.0.0.1', type: 'ip' })
      end

      it 'with label_selector target' do
        test_action(
          :add_target,
          params: { label_selector: { selector: 'test' }, type: 'label_selector' }
        )
      end
    end
  end

  context '#remove_target' do
    it 'handles missing type' do
      expect do
        load_balancer_obj.remove_target(type: nil, ip: '10.0.0.1')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing server' do
      expect do
        load_balancer_obj.remove_target(type: 'server', server: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing ip' do
      expect do
        load_balancer_obj.remove_target(type: 'ip', ip: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing label_selector' do
      expect do
        load_balancer_obj.remove_target(type: 'label_selector', label_selector: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    context 'works' do
      it 'with server target' do
        test_action(:remove_target, params: { server: { id: 42 }, type: 'server' })
      end

      it 'with ip target' do
        test_action(:remove_target, params: { ip: '10.0.0.1', type: 'ip' })
      end

      it 'with label_selector target' do
        test_action(
          :remove_target,
          params: { label_selector: { selector: 'test' }, type: 'label_selector' }
        )
      end
    end
  end
end
