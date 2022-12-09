# frozen_string_literal: true

RSpec.shared_context 'firewalls doubles' do
  def new_firewall(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      created: Faker::Time.backward,
      applied_to: Array.new(Faker::Number.within(range: 0..10)).map { new_applied_to },
      rules: Array.new(Faker::Number.within(range: 0..5)).map { new_rule }
    }.deep_merge(kwargs)
  end

  private

  def new_applied_to
    label_selector = {
      type: 'label_selector',
      label_selector: { selector: Faker::Lorem.words.join(' ') },
      applied_to_resources: Array.new(Faker::Number.within(range: 0..5)).map do
        { type: 'server', server: { id: Faker::Number.number } }
      end
    }
    server = {
      type: 'server',
      server: { id: Faker::Number.number }
    }
    random_choice(label_selector, server)
  end

  def new_rule
    lower_port = Faker::Number.within(range: 1..65_535)
    upper_port = Faker::Number.within(range: lower_port..65_535)

    {
      description: Faker::Lorem.sentence,
      direction: random_choice('in', 'out'),
      source_ips: Array.new(Faker::Number.within(range: 0..10)).map do
        random_choice(Faker::Internet.ip_v4_cidr, Faker::Internet.ip_v6_cidr)
      end,
      destination_ips: Array.new(Faker::Number.within(range: 0..10)).map do
        random_choice(Faker::Internet.ip_v4_cidr, Faker::Internet.ip_v6_cidr)
      end,
      # port can be a single port or a port range
      port: random_choice(lower_port, "#{lower_port}-#{upper_port}"),
      protocol: random_choice('tcp', 'udp', 'icmp', 'esp', 'gre')
    }
  end
end
