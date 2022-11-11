# frozen_string_literal: true

module Hcloud
  class Firewall
    require 'hcloud/firewall_resource'

    include EntryLoader

    updatable :name
    destructible

    has_actions

    def set_rules(rules:) # rubocop:disable Naming/AccessorMethodName
      prepare_request('actions/set_rules', j: COLLECT_ARGS.call(__method__, binding))
    end

    def apply_to_resources(apply_to:)
      prepare_request('actions/apply_to_resources', j: COLLECT_ARGS.call(__method__, binding))
    end

    def remove_from_resources(remove_from:)
      prepare_request('actions/remove_from_resources', j: COLLECT_ARGS.call(__method__, binding))
    end
  end
end
