# frozen_string_literal: true

module Hcloud
  class Volume
    include EntryLoader

    schema(
      created: :time,
      location: Location
    )

    def update(name:)
      prepare_request(j: COLLECT_ARGS.call(__method__, binding), method: :put)
    end

    def attach(server:, automount:)
      prepare_request('actions/attach', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach
      prepare_request('actions/detach', method: :post)
    end

    def resize(size:)
      prepare_request('actions/resize', j: COLLECT_ARGS.call(__method__, binding))
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
