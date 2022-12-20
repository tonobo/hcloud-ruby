# frozen_string_literal: true

module Hcloud
  class LoadBalancerResource < AbstractResource
    filter_attributes :name, :label_selector

    bind_to LoadBalancer

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(
      name:, load_balancer_type:, algorithm:, location: nil, network_zone: nil,
      network: nil, public_interface: nil, services: nil, targets: nil,
      labels: {}
    )
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?
      raise Hcloud::Error::InvalidInput, 'no type given' if load_balancer_type.blank?
      if !algorithm.to_h.key?(:type) || algorithm[:type].blank?
        raise Hcloud::Error::InvalidInput, 'invalid algorithm given'
      end
      if location.blank? && network_zone.blank?
        raise Hcloud::Error::InvalidInput, 'either location or network_zone must be given'
      end

      prepare_request(
        'load_balancers', j: COLLECT_ARGS.call(__method__, binding),
                          expected_code: 201
      ) do |response|
        action = Action.new(client, response[:action]) if response[:action]
        [action, LoadBalancer.new(client, response[:load_balancer])]
      end
    end
  end
end
