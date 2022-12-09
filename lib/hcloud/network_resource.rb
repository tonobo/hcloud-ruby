# frozen_string_literal: true

module Hcloud
  class NetworkResource < AbstractResource
    filter_attributes :name, :label_selector

    bind_to Network

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(name:, ip_range:, subnets: nil, routes: nil, labels: {})
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?
      raise Hcloud::Error::InvalidInput, 'no IP range given' if ip_range.blank?

      prepare_request(
        'networks', j: COLLECT_ARGS.call(__method__, binding),
                    expected_code: 201
      ) do |response|
        Network.new(client, response.parsed_json[:network])
      end
    end
  end
end
