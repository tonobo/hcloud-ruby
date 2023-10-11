# frozen_string_literal: true

module Hcloud
  class FloatingIP
    require 'hcloud/floating_ip_resource'

    include EntryLoader

    schema(
      home_location: Location,
      created: :time
    )

    protectable :delete
    updatable :name, :description
    destructible

    has_actions

    def assign(server:)
      raise Hcloud::Error::InvalidInput, 'no server given' if server.nil?

      prepare_request('actions/assign', j: COLLECT_ARGS.call(__method__, binding))
    end

    def unassign
      prepare_request('actions/unassign', method: :post)
    end

    def change_dns_ptr(ip:, dns_ptr:)
      raise Hcloud::Error::InvalidInput, 'no IP given' if ip.blank?

      prepare_request('actions/change_dns_ptr', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
