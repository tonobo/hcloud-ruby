# frozen_string_literal: true

module Hcloud
  class Pricing
    require 'hcloud/pricing_resource'

    include EntryLoader

    def resource_url
      'pricing'
    end
  end
end
