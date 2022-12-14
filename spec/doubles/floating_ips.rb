# frozen_string_literal: true

RSpec.shared_context 'floating_ips doubles' do
  def new_floating_ip(kwargs = {})
    ip_type = random_choice(:ipv4, :ipv6)

    {
      id: Faker::Number.number,
      ip: ip_type == :ipv4 ? Faker::Internet.ip_v4_address : Faker::Internet.ip_v6_address,
      type: ip_type,
      name: Faker::Internet.slug,
      description: Faker::Lorem.sentence,
      created: Faker::Time.backward,
      blocked: random_choice(true, false),
      dns_ptr: {
        dns_ptr: Faker::Internet.domain_name,
        ip: random_choice(Faker::Internet.ip_v4_address, Faker::Internet.ip_v6_address)
      },
      home_location: new_location,
      server: random_choice(nil, Faker::Number.number),
      protection: { delete: random_choice(true, false) }
    }.deep_merge(kwargs)
  end
end
