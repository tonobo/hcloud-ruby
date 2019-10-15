# frozen_string_literal: true

module Hcloud
  class FloatingIP
    include EntryLoader

    schema(
      home_location: Location,
      created: :time
    )

    protectable :delete
    updatable :description
    destructible

    has_actions

    def assign(server:)
      prepare_request('actions/assign', j: COLLECT_ARGS.call(__method__, binding))
    end

    def unassign
      prepare_request('actions/unassign', method: :post)
    end

    def change_dns_ptr(ip:, dns_ptr:)
      prepare_request('actions/change_dns_ptr', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
