# frozen_string_literal: true

RSpec.shared_context 'datacenters doubles' do
  def new_datacenter(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      location: {
        id: Faker::Number.number,
        name: Faker::Internet.slug,
        description: Faker::Lorem.sentence,
        city: Faker::Address.city,
        country: Faker::Address.country,
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        network_zone: random_choice('eu-central', 'us-west', 'us-east')
      },
      server_types: {
        available: random_server_types,
        available_for_migration: random_server_types,
        supported: random_server_types
      }
    }.deep_merge(kwargs)
  end

  private

  def random_server_types
    server_types = 1..Faker::Number.within(range: 20..150)
    server_types.to_a.sample(Faker::Number.within(range: 0..20))
  end
end
