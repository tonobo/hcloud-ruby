# frozen_string_literal: true

module Hcloud
  class ServerTypeResource < AbstractResource
    filter_attributes :name

    bind_to ServerType

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
