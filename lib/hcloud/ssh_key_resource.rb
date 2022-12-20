# frozen_string_literal: true

module Hcloud
  class SSHKeyResource < AbstractResource
    filter_attributes :name, :label_selector, :fingerprint

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(name:, public_key:, labels: {})
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?

      unless public_key.to_s.starts_with?('ssh')
        raise Hcloud::Error::InvalidInput, 'no valid SSH key given'
      end

      prepare_request(
        'ssh_keys', j: COLLECT_ARGS.call(__method__, binding),
                    expected_code: 201
      ) do |response|
        SSHKey.new(client, response.parsed_json[:ssh_key])
      end
    end
  end
end
