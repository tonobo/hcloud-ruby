# frozen_string_literal: true

module Hcloud
  class FloatingIPResource < AbstractResource
    filter_attributes :name

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(type:, server: nil, home_location: nil, description: nil)
      prepare_request(
        'floating_ips', j: COLLECT_ARGS.call(__method__, binding), code: 201
      ) do |response|
        action = Action.new(client, response[:action]) if response[:action]
        [action, FloatingIP.new(client, response[:floating_ip])]
      end
    end
  end
end
