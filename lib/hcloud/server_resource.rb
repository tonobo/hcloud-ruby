# frozen_string_literal: true

module Hcloud
  class ServerResource < AbstractResource
    filter_attributes :status, :name

    def create(name:,
               server_type:,
               datacenter: nil,
               location: nil,
               start_after_create: nil,
               image:,
               ssh_keys: [],
               networks: [],
               user_data: nil)
      prepare_request('servers', j: COLLECT_ARGS.call(__method__, binding),
                                 expected_code: 201) do |response|
        [
          Action.new(client, response.parsed_json[:action]),
          Server.new(client, response.parsed_json[:server]),
          response.parsed_json[:root_password]
        ]
      end
    end

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
