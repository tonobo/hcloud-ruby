# frozen_string_literal: true

module Hcloud
  class Firewall
    require 'hcloud/firewall_resource'

    include EntryLoader

    schema(
      created: :time
    )

    updatable :name
    destructible

    has_actions

    def set_rules(rules:)
      # Set rules to empty when nil is passed
      rules = rules.to_a

      prepare_request('actions/set_rules', j: COLLECT_ARGS.call(__method__, binding))
    end

    def apply_to_resources(apply_to:)
      raise Hcloud::Error::InvalidInput, 'no apply_to resources given' if apply_to.nil?

      prepare_request('actions/apply_to_resources', j: COLLECT_ARGS.call(__method__, binding))
    end

    def remove_from_resources(remove_from:)
      raise Hcloud::Error::InvalidInput, 'no remove_from resources given' if remove_from.nil?

      prepare_request('actions/remove_from_resources', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
