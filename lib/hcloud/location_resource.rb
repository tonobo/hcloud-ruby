# frozen_string_literal: true

module Hcloud
  class LocationResource < AbstractResource
    filter_attributes :name

    bind_to Location

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
