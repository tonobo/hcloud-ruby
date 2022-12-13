# frozen_string_literal: true

module Hcloud
  class LoadBalancerTypeResource < AbstractResource
    filter_attributes :name

    bind_to LoadBalancerType

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
