# frozen_string_literal: true

module Hcloud
  class FloatingIP
    include EntryLoader

    schema(
      home_location: Location,
      created: :time
    )

    def update(description:)
      prepare_request(j: COLLECT_ARGS.call(__method__, binding), method: :put)
    end

    def assign(server:)
      prepare_request('actions/assign', j: COLLECT_ARGS.call(__method__, binding))
    end

    def unassign
      prepare_request('actions/unassign', method: :post)
    end

    def change_dns_ptr(ip:, dns_ptr:)
      prepare_request('actions/change_dns_ptr', j: COLLECT_ARGS.call(__method__, binding))
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
