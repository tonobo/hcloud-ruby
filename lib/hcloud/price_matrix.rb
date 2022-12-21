# frozen_string_literal: true

require 'forwardable'

module Hcloud
  class PriceMatrix
    extend Forwardable
    include Enumerable

    def_delegator :@prices, :each

    def initialize(prices, type)
      validate_prices(prices)

      @prices = prices
      @type = type
      @attributes = prices[0].to_h.keys.reject { |key| key == :prices }
    end

    def filter(**kwargs)
      PriceMatrix.new(filter_raw(kwargs), @type)
    end

    def estimated_cost(location, **kwargs)
      filter_keys, calc_keys = kwargs.keys.partition { |key| @attributes.include?(key) }
      filter_args = kwargs.slice(*filter_keys)
      filter_args = filter_args.merge(location: location) if @attributes.include?(:location)

      entries = filter_raw(filter_args)
      # TODO: Not so nice behaviour for users
      unless entries.count == 1
        raise Hcloud::Error::InvalidInput,
              "could not filter to a single element, got #{entries.count}"
      end

      calc_cost(kwargs.slice(*calc_keys), entries[0][:prices])
    end

    private

    def calc_cost(calc_args, prices)
      # TODO: How to standardize this more?
      case @type
      when :floating_ip
        calc_month_based(calc_args, prices, months_key: :months)
      when :primary_ip
        calc_hour_based(calc_args, prices, hours_key: :hours)
      when :image, :volume
        calc_gb_based(calc_args, prices)
      when :load_balancer_type, :server_type
        calc_hour_based(calc_args, prices, hours_key: :runtime_hours)
      when :traffic
        calc_traffic(calc_args, prices)
      end
    end

    def validate_prices(prices)
      unless prices.all? { |entry| entry.key?(:prices) }
        raise Hcloud::Error::InvalidInput, 'Key "prices" missing in pricing data'
      end

      prices.each do |entry|
        entry[:prices].each do |type, price|
          unless price.key?(:net)
            raise Hcloud::Error::InvalidInput, "Key \"net\" missing for price \"#{type}\""
          end
        end
      end
    end

    def filter_raw(filters)
      @prices.select do |price|
        price.all? do |key, value|
          !filters.key?(key) || filters[key] == value
        end
      end
    end

    def calc_hour_based(calc_args, price, hours_key:)
      check_keys(calc_args.keys, [hours_key])

      # TODO: Take into account monthly cap for capped prices. Add a spec for it.
      price[:price_hourly][:net] * calc_args[hours_key]
    end

    def calc_month_based(calc_args, price, months_key:)
      check_keys(calc_args.keys, [months_key])

      price[:price_monthly][:net] * calc_args[months_key]
    end

    def calc_gb_based(calc_args, price)
      check_keys(calc_args.keys, [:size_gb])

      price[:price_per_gb_month][:net] * calc_args[:size_gb]
    end

    def calc_traffic(calc_args, price)
      check_keys(calc_args.keys, [:traffic_tb])

      price[:price_per_tb][:net] * calc_args[:traffic_tb]
    end

    def check_keys(keys, required, allowed = nil)
      allowed ||= required

      check_required_keys(keys, required)
      check_allowed_keys(keys, allowed)
    end

    def check_allowed_keys(keys, allowed_keys)
      diff = keys.difference(allowed_keys)

      return if diff.empty?

      raise Hcloud::Error::InvalidInput, "Parameter(s) \"#{diff.join(', ')}\" not allowed"
    end

    def check_required_keys(keys, required_keys)
      diff = required_keys.difference(keys)

      return if diff.empty?

      raise Hcloud::Error::InvalidInput, "Parameter(s) \"#{diff.join(', ')}\" missing"
    end
  end
end
