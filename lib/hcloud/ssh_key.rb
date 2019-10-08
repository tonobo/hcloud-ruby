# frozen_string_literal: true

module Hcloud
  class SSHKey
    include EntryLoader

    def update(name:)
      prepare_request(j: COLLECT_ARGS.call(__method__, binding), method: :put)
    end

    def destroy
      prepare_request(method: :delete)
      true
    end
  end
end
