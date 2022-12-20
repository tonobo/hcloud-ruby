# frozen_string_literal: true

RSpec.shared_context 'primary_ips doubles' do
  def new_primary_ip(kwargs = {})
    ip_type = random_choice(:ipv4, :ipv6)

    {
      id: Faker::Number.number,
      ip: ip_type == :ipv4 ? Faker::Internet.ip_v4_address : Faker::Internet.ip_v6_cidr,
      type: ip_type,
      name: Faker::Internet.slug,
      auto_delete: random_choice(true, false),
      created: Faker::Time.backward,
      blocked: random_choice(true, false),
      assignee_id: random_choice(nil, Faker::Number.number),
      assignee_type: 'server',
      dns_ptr: {
        dns_ptr: Faker::Internet.domain_name,
        ip: random_choice(Faker::Internet.ip_v4_address, Faker::Internet.ip_v6_address)
      },
      datacenter: new_datacenter,
      protection: { delete: random_choice(true, false) }
    }.deep_merge(kwargs)
  end
end
