# frozen_string_literal: true

module Hcloud
  class CertificateResource < AbstractResource
    filter_attributes :name, :label_selector, :type

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(
      name:,
      type: :uploaded,
      certificate: nil,
      private_key: nil,
      domain_names: nil,
      labels: {}
    )
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?

      case type
      when :uploaded
        raise Hcloud::Error::InvalidInput, 'no certificate given' if certificate.blank?
        raise Hcloud::Error::InvalidInput, 'no private_key given' if private_key.blank?
      when :managed
        raise Hcloud::Error::InvalidInput, 'no domain_names given' if domain_names.to_a.empty?
      end

      prepare_request(
        'certificates', j: COLLECT_ARGS.call(__method__, binding),
                        expected_code: 201
      ) do |response|
        [
          Action.new(client, response.parsed_json[:action]),
          Certificate.new(client, response.parsed_json[:certificate])
        ]
      end
    end
  end
end
