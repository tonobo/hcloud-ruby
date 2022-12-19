# frozen_string_literal: true

module Hcloud
  class Certificate
    require 'hcloud/certificate_resource'

    include EntryLoader

    schema(
      created: :time
    )

    updatable :name
    destructible

    has_actions

    def retry
      prepare_request('actions/retry', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
