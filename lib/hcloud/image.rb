# frozen_string_literal: true

module Hcloud
  class Image
    include EntryLoader

    schema(
      created: :time,
      deprecated: :time
    )

    def to_snapshot
      update(type: 'snapshot')
    end

    def update(description: nil, type: nil)
      prepare_request(j: COLLECT_ARGS.call(__method__, binding), method: :put)
    end

    def change_protection(delete: nil)
      prepare_request('actions/change_protection', j: COLLECT_ARGS.call(__method__, binding))
    end

    def destroy
      prepare_request(method: :delete)
      true
    end
  end
end
