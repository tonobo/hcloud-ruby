# frozen_string_literal: true

module Hcloud
  class Image
    include EntryLoader

    schema(
      created: :time,
      deprecated: :time
    )

    protectable :delete
    updatable :description, :type
    destructible

    def to_snapshot
      update(type: 'snapshot')
    end
  end
end
