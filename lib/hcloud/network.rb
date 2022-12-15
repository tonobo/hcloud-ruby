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
      raise Hcloud::Error::InvalidInput, 'no type given' if type.blank?
      raise Hcloud::Error::InvalidInput, 'no network_zone given' if network_zone.blank?

      prepare_request('actions/add_subnet', j: COLLECT_ARGS.call(__method__, binding))
    end

    def del_subnet(ip_range:)
      raise Hcloud::Error::InvalidInput, 'no ip_range given' if ip_range.blank?

      prepare_request('actions/delete_subnet', j: COLLECT_ARGS.call(__method__, binding))
    end

    def add_route(destination:, gateway:)
      raise Hcloud::Error::InvalidInput, 'no destination given' if destination.blank?
      raise Hcloud::Error::InvalidInput, 'no gateway given' if gateway.blank?

      prepare_request('actions/add_route', j: COLLECT_ARGS.call(__method__, binding))
    end

    def del_route(destination:, gateway:)
      raise Hcloud::Error::InvalidInput, 'no destination given' if destination.blank?
      raise Hcloud::Error::InvalidInput, 'no gateway given' if gateway.blank?

      prepare_request('actions/delete_route', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_ip_range(ip_range:)
      raise Hcloud::Error::InvalidInput, 'no ip_range given' if ip_range.blank?

      prepare_request('actions/change_ip_range', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
