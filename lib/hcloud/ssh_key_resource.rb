# frozen_string_literal: true

module Hcloud
  class SSHKeyResource < AbstractResource
    filter_attributes :name

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(name:, public_key:)
      prepare_request(
        'ssh_keys', j: COLLECT_ARGS.call(__method__, binding),
                    expected_code: 201
      ) do |response|
        SSHKey.new(client, response.parsed_json[:ssh_key])
      end
    end
  end
end
