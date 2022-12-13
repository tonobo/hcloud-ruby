# frozen_string_literal: true

RSpec.shared_context 'load_balancer_types doubles' do
  def new_load_balancer_type(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      max_assigned_certificates: Faker::Number.within(range: 10..50),
      max_connections: Faker::Number.number,
      max_services: Faker::Number.within(range: 5..30),
      max_targets: Faker::Number.within(range: 25..150),
      deprecated: random_choice(nil, Faker::Time.backward),
      prices: Array.new(Faker::Number.within(range: 1..3)).map { new_load_balancer_price }
    }.deep_merge(kwargs)
  end

  private

  def new_load_balancer_price
    {
      location: random_choice('fsn1', 'hel1', 'nbg1', 'hil', 'ash'),
      price_hourly: {
        gross: Faker::Number.decimal(l_digits: 2, r_digits: 6).to_s,
        net: Faker::Number.decimal(l_digits: 2, r_digits: 6).to_s
      },
      price_monthly: {
        gross: Faker::Number.decimal(l_digits: 2, r_digits: 6).to_s,
        net: Faker::Number.decimal(l_digits: 2, r_digits: 6).to_s
      }
    }
  end
end
