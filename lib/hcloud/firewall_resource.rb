# frozen_string_literal: true

module Hcloud
  class FirewallResource < AbstractResource
    filter_attributes :name

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(name:, rules: [], apply_to: [])
      prepare_request(
        'firewalls', j: COLLECT_ARGS.call(__method__, binding),
                     expected_code: 201
      ) do |response|
        Firewall.new(client, response.parsed_json[:firewall])
      end
    end
  end
end
