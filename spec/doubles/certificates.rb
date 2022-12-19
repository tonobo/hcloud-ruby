# frozen_string_literal: true

RSpec.shared_context 'certificates doubles' do
  def new_certificate(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      created: Faker::Time.backward,
      type: random_choice(:uploaded, :managed),
      certificate: random_choice(nil, '-----BEGIN CERTIFICATE-----'),
      fingerprint: Faker::Crypto.md5.chars.each_slice(2).map(&:join).join(':'),
      domain_names: Array.new(Faker::Number.within(range: 0..5)).map do
        Faker::Internet.domain_name
      end,
      not_valid_after: random_choice(Faker::Time.forward, Faker::Time.backward),
      not_valid_before: random_choice(Faker::Time.forward, Faker::Time.backward),
      status: new_certificate_status,
      used_by: Array.new(Faker::Number.within(range: 0..3)).map do
        { id: Faker::Number.number, type: 'load_balancer' }
      end
    }.deep_merge(kwargs)
  end

  def new_certificate_status
    random_choice(
      nil,
      {
        issuance: random_choice(:pending, :completed, :failed),
        renewal: random_choice(:scheduled, :pending, :failed, :unavailable)
      }
    )
  end
end
