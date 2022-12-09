# frozen_string_literal: true

RSpec.shared_context 'locations doubles' do
  def new_location(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      city: Faker::Address.city,
      country: Faker::Address.country,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      network_zone: random_choice('eu-central', 'us-west', 'us-east')
    }.deep_merge(kwargs)
  end
end
