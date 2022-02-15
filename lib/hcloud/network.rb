# frozen_string_literal: true

module Hcloud
  class Network
    include EntryLoader

    schema(
      created: :time
    )

    protectable :delete
    updatable :name
    destructible

    has_actions

    def add_subnet(type:, network_zone:, ip_range: nil)
      prepare_request('actions/add_subnet', j: COLLECT_ARGS.call(__method__, binding))
    end

    def del_subnet(ip_range:)
      prepare_request('actions/del_subnet', j: COLLECT_ARGS.call(__method__, binding))
    end

    def add_route(destination:, gateway:)
      prepare_request('actions/add_route', j: COLLECT_ARGS.call(__method__, binding))
    end

    def del_route(destination:, gateway:)
      prepare_request('actions/del_route', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
