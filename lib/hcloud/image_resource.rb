# frozen_string_literal: true

module Hcloud
  class ImageResource < AbstractResource
    filter_attributes :type, :bound_to, :name, :label_selector

    bind_to Image

    def [](arg)
      case arg
      when Integer then find_by(id: arg)
      when String then find_by(name: arg)
      end
    end
  end
end
