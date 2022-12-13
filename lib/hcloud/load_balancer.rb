# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'

module Hcloud
  class LoadBalancer
    require 'hcloud/load_balancer_resource'

    include EntryLoader

    schema(
      location: Location,
      load_balancer_type: LoadBalancerType,
      created: :time
    )

    protectable :delete
    updatable :name
    destructible

    has_metrics
    has_actions

    %w[enable_public_interface disable_public_interface].each do |action|
      define_method(action) do
        prepare_request("actions/#{action}", method: :post)
      end
    end

    def attach_to_network(network:, ip: nil)
      raise Hcloud::Error::InvalidInput, 'no network given' if network.nil?

      prepare_request('actions/attach_to_network', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach_from_network(network:)
      raise Hcloud::Error::InvalidInput, 'no network given' if network.nil?

      prepare_request('actions/detach_from_network', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_dns_ptr(ip:, dns_ptr:)
      raise Hcloud::Error::InvalidInput, 'no IP given' if ip.blank?
      raise Hcloud::Error::InvalidInput, 'no dns_ptr given' if dns_ptr.blank?

      prepare_request('actions/change_dns_ptr', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_type(load_balancer_type:)
      raise Hcloud::Error::InvalidInput, 'no type given' if load_balancer_type.blank?

      prepare_request('actions/change_type', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_algorithm(type:)
      raise Hcloud::Error::InvalidInput, 'no type given' if type.blank?

      prepare_request('actions/change_algorithm', j: COLLECT_ARGS.call(__method__, binding))
    end

    def add_service(
      protocol:, listen_port:, destination_port:, health_check:, proxyprotocol:, http: nil
    )
      validate_service_input(
        protocol: protocol,
        listen_port: listen_port,
        destination_port: destination_port,
        health_check: health_check,
        proxyprotocol: proxyprotocol
      )

      prepare_request('actions/add_service', j: COLLECT_ARGS.call(__method__, binding))
    end

    def update_service(
      protocol:, listen_port:, destination_port:, health_check:, proxyprotocol:, http: nil
    )
      validate_service_input(
        protocol: protocol,
        listen_port: listen_port,
        destination_port: destination_port,
        health_check: health_check,
        proxyprotocol: proxyprotocol
      )

      prepare_request('actions/update_service', j: COLLECT_ARGS.call(__method__, binding))
    end

    def delete_service(listen_port:)
      raise Hcloud::Error::InvalidInput, 'no listen_port given' if listen_port.nil?

      prepare_request('actions/delete_service', j: COLLECT_ARGS.call(__method__, binding))
    end

    def add_target(type:, server: nil, label_selector: nil, ip: nil, use_private_ip: false)
      validate_target_input(
        type: type, server: server, label_selector: label_selector, ip: ip
      )

      prepare_request('actions/add_target', j: COLLECT_ARGS.call(__method__, binding))
    end

    def remove_target(type:, server: nil, label_selector: nil, ip: nil)
      validate_target_input(
        type: type, server: server, label_selector: label_selector, ip: ip
      )

      prepare_request('actions/remove_target', j: COLLECT_ARGS.call(__method__, binding))
    end

    private

    def validate_service_input(
      protocol:, listen_port:, destination_port:, health_check:, proxyprotocol:
    )
      raise Hcloud::Error::InvalidInput, 'no protocol given' if protocol.blank?
      raise Hcloud::Error::InvalidInput, 'no listen_port given' if listen_port.nil?
      raise Hcloud::Error::InvalidInput, 'no destination_port given' if destination_port.nil?
      raise Hcloud::Error::InvalidInput, 'no health_check given' if health_check.nil?
      raise Hcloud::Error::InvalidInput, 'no proxyprotocol given' if proxyprotocol.nil?
    end

    def validate_target_input(type:, server: nil, label_selector: nil, ip: nil)
      raise Hcloud::Error::InvalidInput, 'no type given' if type.nil?

      case type.to_sym
      when :server
        raise Hcloud::Error::InvalidInput, 'invalid server given' unless server.to_h.key?(:id)
      when :ip
        raise Hcloud::Error::InvalidInput, 'no IP given' if ip.blank?
      when :label_selector
        unless label_selector.to_h.key?(:selector)
          raise Hcloud::Error::InvalidInput, 'invalid label_selector given'
        end
      else
        raise Hcloud::Error::InvalidInput, 'invalid type given'
      end
    end
  end
end
