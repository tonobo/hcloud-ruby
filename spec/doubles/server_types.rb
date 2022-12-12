# frozen_string_literal: true

RSpec.shared_context 'server_types doubles' do
  def new_server_type(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      cores: Faker::Number.within(range: 1..32),
      cpu_type: random_choice('shared', 'dedicated'),
      deprecated: random_choice(true, false),
      disk: Faker::Number.within(range: 1..500),
      memory: Faker::Number.within(range: 1..128),
      prices: {
        location: random_choice('fsn1', 'nbg1', 'hel1', 'ash', 'hil'),
        price_hourly: {
          net: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          gross: Faker::Number.decimal(l_digits: 2, r_digits: 2)
        },
        price_monthly: {
          net: Faker::Number.decimal(l_digits: 2, r_digits: 2),
          gross: Faker::Number.decimal(l_digits: 2, r_digits: 2)
        }
      },
      storage_type: random_choice('local', 'network')
    }.deep_merge(kwargs)
  end
end
