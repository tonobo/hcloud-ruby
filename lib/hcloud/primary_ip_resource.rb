# frozen_string_literal: true

module Hcloud
  class PrimaryIPResource < AbstractResource
    filter_attributes :name, :label_selector, :ip

    bind_to PrimaryIP

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(
      name:,
      type:,
      assignee_id: nil,
      assignee_type: 'server',
      datacenter: nil,
      auto_delete: nil,
      labels: {}
    )
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?

      unless %w[ipv4 ipv6].include?(type.to_s)
        raise Hcloud::Error::InvalidInput, 'invalid type given'
      end

      raise Hcloud::Error::InvalidInput, 'no assignee_type given' if assignee_type.blank?

      if assignee_id.nil? && datacenter.nil?
        raise Hcloud::Error::InvalidInput, 'either assignee_id or datacenter must be given'
      end

      prepare_request(
        'primary_ips', j: COLLECT_ARGS.call(__method__, binding),
                       expected_code: 201
      ) do |response|
        action = Action.new(client, response[:action]) if response[:action]
        [action, PrimaryIP.new(client, response[:primary_ip])]
      end
    end
  end
end
