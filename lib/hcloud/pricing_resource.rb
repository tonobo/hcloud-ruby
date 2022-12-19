# frozen_string_literal: true

module Hcloud
  class PricingResource < AbstractResource
    bind_to Pricing

    def fetch
      prepare_request('pricing', method: :get) do |response|
        Pricing.new(client, response.parsed_json[:pricing])
      end
    end
  end
end
