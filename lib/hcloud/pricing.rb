# frozen_string_literal: true

require 'bigdecimal'

module Hcloud
  class Pricing
    require 'hcloud/price_matrix'

    attr_reader :currency

    def initialize(client)
      @client = client
      reload
    end

    def respond_to_missing?(method_name, include_all = false)
      @matrices.key?(method_name) || super
    end

    def method_missing(method_name, *args)
      @matrices[method_name] || super
    end

    private

    def reload # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      @matrices = {}

      @client.prepare_request('pricing') do |response|
        data = response.parsed_json[:pricing]

        @currency = data[:currency]
        @matrices[:floating_ips] = Hcloud::PriceMatrix.new(
          parse_location_pricing(data[:floating_ips]), :floating_ip
        )
        @matrices[:images] = Hcloud::PriceMatrix.new(parse_global_pricing(data[:image]), :image)
        @matrices[:load_balancer_types] = Hcloud::PriceMatrix.new(
          parse_location_pricing(data[:load_balancer_types]), :load_balancer_type
        )
        @matrices[:primary_ips] = Hcloud::PriceMatrix.new(
          parse_location_pricing(data[:primary_ips]), :primary_ip
        )
        # TODO: Server backup does not fulfill the current requirement to have a "net" key
        @matrices[:server_types] = Hcloud::PriceMatrix.new(
          parse_location_pricing(data[:server_types]), :server_type
        )
        @matrices[:traffic] = Hcloud::PriceMatrix.new(
          parse_global_pricing(data[:traffic]), :traffic
        )
        @matrices[:volumes] = Hcloud::PriceMatrix.new(parse_global_pricing(data[:volume]), :volume)
      end
    end

    def parse_global_pricing(pricing)
      pricing.each do |key, value|
        pricing[key][:net] = BigDecimal(value[:net])
        pricing[key][:gross] = BigDecimal(value[:gross])
      end

      [{ prices: pricing }]
    end

    def parse_location_pricing(pricing)
      result = []

      pricing.each do |per_type|
        prices = per_type.delete(:prices)
        prices.each do |per_location|
          location = per_location.delete(:location)

          per_location.each do |key, value|
            per_location[key][:net] = BigDecimal(value[:net])
            per_location[key][:gross] = BigDecimal(value[:gross])
          end

          result << per_type.merge(prices: per_location).merge(location: location)
        end
      end

      result
    end
  end
end
