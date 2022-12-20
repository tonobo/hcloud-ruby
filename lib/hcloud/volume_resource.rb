# frozen_string_literal: true

module Hcloud
  class VolumeResource < AbstractResource
    filter_attributes :name, :label_selector, :status

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end

    def create(size:, name:, automount: nil, format: nil, location: nil, server: nil, labels: {})
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?
      raise Hcloud::Error::InvalidInput, 'invalid size given' unless size.to_i >= 10
      if location.blank? && server.nil?
        raise Hcloud::Error::InvalidInput, 'location or server must be given'
      end

      prepare_request(
        'volumes', j: COLLECT_ARGS.call(__method__, binding),
                   expected_code: 201
      ) do |response|
        [
          Action.new(client, response.parsed_json[:action]),
          Volume.new(client, response.parsed_json[:volume]),
          response.parsed_json[:next_actions].map do |action|
            Action.new(client, action)
          end
        ]
      end
    end
  end
end
