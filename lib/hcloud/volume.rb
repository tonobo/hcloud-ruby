# frozen_string_literal: true

module Hcloud
  class Volume
    include EntryLoader

    schema(
      created: :time,
      location: Location
    )

    protectable :delete
    updatable :name
    destructible

    has_actions

    def attach(server:, automount:)
      prepare_request('actions/attach', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach
      prepare_request('actions/detach', method: :post)
    end

    def resize(size:)
      prepare_request('actions/resize', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
