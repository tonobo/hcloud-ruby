# frozen_string_literal: true

RSpec.shared_context 'networks doubles' do
  def new_network(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      ip_range: Faker::Internet.ip_v4_cidr,
      created: Faker::Time.backward,
      load_balancers: Array.new(Faker::Number.within(range: 0..10)).map { Faker::Number.number },
      servers: Array.new(Faker::Number.within(range: 0..10)).map { Faker::Number.number },
      protection: { delete: random_choice(true, false) },
      routes: Array.new(Faker::Number.within(range: 0..10)).map { new_route },
      subnets: Array.new(Faker::Number.within(range: 0..10)).map { new_subnet }
    }.deep_merge(kwargs)
  end

  private

  def new_route
    {
      destination: Faker::Internet.ip_v4_cidr,
      gateway: Faker::Internet.private_ip_v4_address
    }
  end

  def new_subnet
    {
      gateway: Faker::Internet.private_ip_v4_address,
      ip_range: Faker::Internet.ip_v4_cidr,
      network_zone: random_choice('eu-central', 'us-west', 'eu-west'),
      type: 'cloud'
    }
  end
end
