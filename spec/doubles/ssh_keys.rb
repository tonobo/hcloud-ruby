# frozen_string_literal: true

RSpec.shared_context 'ssh_keys doubles' do
  def new_ssh_key(kwargs = {})
    {
      id: Faker::Number.number,
      name: Faker::Internet.slug,
      created: Faker::Time.backward,
      fingerprint: Faker::Crypto.md5.chars.each_slice(2).map(&:join).join(':'),
      # not really a SSH key, but should be enough for tests
      public_key: "#{random_choice('ssh-rsa', 'ssh-ed25519')} " \
                  "#{Faker::Lorem.characters} #{Faker::Internet.slug}"
    }.deep_merge(kwargs)
  end
end
