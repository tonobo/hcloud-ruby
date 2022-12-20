# frozen_string_literal: true

RSpec.shared_context 'load_balancers doubles' do
  def new_load_balancer(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      algorithm: { type: random_choice('round_robin', 'least_connections') },
      created: Faker::Time.backward,
      included_traffic: Faker::Number.number,
      ingoing_traffic: Faker::Number.number,
      outgoing_traffic: Faker::Number.number,
      private_net: Array.new(Faker::Number.within(range: 1..5)).map { new_load_balancer_priv_net },
      public_net: {
        enabled: random_choice(true, false),
        ipv4: {
          dns_ptr: random_choice(nil, Faker::Internet.domain_name),
          ip: random_choice(nil, Faker::Internet.public_ip_v4_address)
        },
        ipv6: {
          dns_ptr: random_choice(nil, Faker::Internet.domain_name),
          ip: random_choice(nil, Faker::Internet.ip_v6_address)
        }
      },
      protection: { delete: random_choice(true, false) },
      services: Array.new(Faker::Number.within(range: 0..5)).map { new_load_balancer_service },
      targets: Array.new(Faker::Number.within(range: 0..20)).map { new_load_balancer_target }
    }.deep_merge(kwargs)
  end

  def new_load_balancer_service
    # choose a few random status codes from a list of examples
    http_codes = [
      '2??', '3??', '4??', '5??',
      '2*', '3*', '4*', '5*',
      '200', '300', '400', '500'
    ]
    status_codes = http_codes.sample(Faker::Number.within(range: 1..4)).join(',')

    {
      listen_port: Faker::Number.within(range: 1..65_535),
      destination_port: Faker::Number.within(range: 1..65_535),
      protocol: random_choice('tcp', 'http', 'https'),
      proxyprotocol: random_choice(true, false),
      http: {
        certificates: Array.new(Faker::Number.within(range: 0..5)).map { Faker::Number.number },
        cookie_lifetime: Faker::Number.within(range: 60..600),
        cookie_name: Faker::Internet.slug,
        redirect_http: random_choice(true, false),
        sticky_sessions: random_choice(true, false)
      },
      health_check: {
        protocol: random_choice('tcp', 'http'),
        port: Faker::Number.within(range: 1..65_535),
        interval: Faker::Number.within(range: 10..60),
        retries: Faker::Number.within(range: 1..10),
        timeout: Faker::Number.within(range: 10..60),
        http: {
          domain: random_choice(nil, Faker::Internet.domain_name),
          path: random_choice('/', "/#{Faker::Internet.slug}"),
          response: random_choice(nil, Faker::Lorem.sentence),
          status_codes: status_codes,
          tls: random_choice(true, false)
        }
      }
    }
  end

  def new_load_balancer_target(allowed_types = %i[server ip label_selector])
    chosen_type = allowed_types.sample

    case chosen_type
    when :server
      {
        server: { id: Faker::Number.number },
        health_status: {
          listen_port: Faker::Number.within(range: 1..65_535),
          status: random_choice('healthy', 'unhealthy', 'unknown')
        },
        use_private_ip: random_choice(true, false),
        type: chosen_type.to_s
      }
    when :ip
      {
        ip: { ip: random_choice(Faker::Internet.ip_v4_address, Faker::Internet.ip_v6_address) },
        health_status: {
          listen_port: Faker::Number.within(range: 1..65_535),
          status: random_choice('healthy', 'unhealthy', 'unknown')
        },
        type: chosen_type.to_s
      }
    when :label_selector
      {
        label_selector: { selector: Faker::Lorem.words(number: 4).join(' ') },
        targets: Array.new(Faker::Number.within(range: 0..5)).map do
          new_load_balancer_target([:server])
        end
      }
    end
  end

  private

  def new_load_balancer_priv_net
    {
      ip: Faker::Internet.public_ip_v4_address,
      network: Faker::Number.number
    }
  end
end
