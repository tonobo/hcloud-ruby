# frozen_string_literal: true

RSpec.shared_context 'pricings doubles' do
  def new_pricing(kwargs = {})
    {
      pricing: {
        currency: Faker::Currency.code,
        floating_ip: {
          price_monthly: new_pricings_price
        },
        floating_ips: [
          {
            prices: new_pricings_regional(hourly: false),
            type: random_choice('ipv4', 'ipv6')
          }
        ],
        image: {
          price_per_gb_month: new_pricings_price
        },
        load_balancer_types: [
          {
            id: Faker::Number.number,
            name: Faker::Internet.slug,
            prices: new_pricings_regional
          }
        ],
        primary_ips: [
          {
            type: random_choice('ipv4', 'ipv6'),
            prices: new_pricings_regional
          }
        ],
        server_backup: {
          percentage: Faker::Number.within(range: 0.0..100.0)
        },
        server_types: [
          {
            id: Faker::Number.number,
            name: Faker::Internet.slug,
            prices: new_pricings_regional
          }
        ],
        traffic: {
          price_per_tb: new_pricings_price
        },
        vat_rate: Faker::Number.within(range: 5.0..35.0),
        volume: {
          price_per_gb_month: new_pricings_price
        }
      }
    }.deep_merge(kwargs)
  end

  private

  def new_pricings_price
    {
      gross: Faker::Number.decimal.to_s,
      net: Faker::Number.decimal.to_s
    }
  end

  def new_pricings_regional(hourly: true, monthly: true)
    price = {
      location: Faker::Internet.slug
    }

    price[:price_hourly] = new_pricings_price if hourly
    price[:price_monthly] = new_pricings_price if monthly

    [price]
  end
end
