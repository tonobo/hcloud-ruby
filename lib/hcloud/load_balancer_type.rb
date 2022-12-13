# frozen_string_literal: true

module Hcloud
  class LoadBalancerType
    require 'hcloud/load_balancer_type_resource'

    include EntryLoader

    schema(
      deprecated: :time
    )
  end
end
