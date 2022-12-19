# frozen_string_literal: true

module Hcloud
  class FirewallResource < AbstractResource
    filter_attributes :name, :label_selector

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(name:, rules: [], apply_to: [], labels: {})
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?

      prepare_request(
        'firewalls', j: COLLECT_ARGS.call(__method__, binding),
                     expected_code: 201
      ) do |response|
        [
          response.parsed_json[:actions].map do |action|
            Action.new(client, action)
          end,
          Firewall.new(client, response.parsed_json[:firewall])
        ]
      end
    end
  end
end
