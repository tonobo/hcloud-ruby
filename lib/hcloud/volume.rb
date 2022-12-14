# frozen_string_literal: true

module Hcloud
  class Volume
    require 'hcloud/volume_resource'

    include EntryLoader

    schema(
      created: :time,
      location: Location
    )

    protectable :delete
    updatable :name
    destructible

    has_actions

    def attach(server:, automount: nil)
      raise Hcloud::Error::InvalidInput, 'no server given' if server.nil?

      prepare_request('actions/attach', j: COLLECT_ARGS.call(__method__, binding))
    end

    def detach
      prepare_request('actions/detach', method: :post)
    end

    def resize(size:)
      raise Hcloud::Error::InvalidInput, 'invalid size given' unless size.to_i > self.size

      prepare_request('actions/resize', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
