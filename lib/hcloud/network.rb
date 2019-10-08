# frozen_string_literal: true

module Hcloud
  class Network
    include EntryLoader

    schema(
      created: :time
    )

    def update(name:)
      prepare_request(j: COLLECT_ARGS.call(__method__, binding), method: :put)
    end

    def add_subnet(type:, ip_range: nil, network_zone:)
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

    def change_ip_range(ip_range:)
      prepare_request('actions/change_ip_range', j: COLLECT_ARGS.call(__method__, binding))
    end

    def change_protection(delete: nil)
      prepare_request('actions/change_protection', j: COLLECT_ARGS.call(__method__, binding))
    end

    def actions
      ActionResource.new(client: client, base_path: resource_url)
    end

    def destroy
      prepare_request(method: :delete)
      true
    end
  end
end
