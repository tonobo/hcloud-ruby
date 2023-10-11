# frozen_string_literal: true

module Hcloud
  class PlacementGroupResource < AbstractResource
    filter_attributes :type, :name, :label_selector

    bind_to PlacementGroup

    def [](arg)
      return find_by(name: arg) if arg.is_a?(String)

      super
    end

    # currently only spread is available
    def create(name:, type: 'spread', labels: {})
      if type.to_s != 'spread'
        raise Hcloud::Error::InvalidInput, "invalid type #{type.inspect}, only 'spread' is allowed"
      end
      raise Hcloud::Error::InvalidInput, 'no name given' if name.blank?

      prepare_request(
        'placement_groups', j: COLLECT_ARGS.call(__method__, binding),
                            expected_code: 201
      ) do |response|
        PlacementGroup.new(client, response.parsed_json[:placement_group])
      end
    end
  end
end
