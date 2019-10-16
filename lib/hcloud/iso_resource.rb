# frozen_string_literal: true

module Hcloud
  class IsoResource < AbstractResource
    filter_attributes :name

    bind_to Iso

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
