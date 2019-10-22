# frozen_string_literal: true

module Hcloud
  class DatacenterResource < AbstractResource
    filter_attributes :name

    bind_to Datacenter

    def recommended
      all.first
    end

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
