# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels'

SSH_KEY = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILh8GHJkJRgf3wuuUUQYG3UfqtVK56+FEXAOFaNZ659C m@x.com'

describe Hcloud::SSHKey, doubles: :ssh_key do
  include_context 'test doubles'

  let :ssh_keys do
    Array.new(Faker::Number.within(range: 20..150)).map { new_ssh_key }
  end

  let(:ssh_key) { ssh_keys.sample }

  let(:ssh_pub_key) { SSH_KEY }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { name: 'new_name' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels', described_class, { name: 'moo', public_key: SSH_KEY }

  context '#create' do
    it 'handle missing name' do
      expect { client.ssh_keys.create(name: nil, public_key: 'ssh-rsa') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle missing public_key' do
      expect { client.ssh_keys.create(name: 'moo', public_key: nil) }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'handle invalid public_key' do
      expect { client.ssh_keys.create(name: 'moo', public_key: 'not-ssh') }.to(
        raise_error(Hcloud::Error::InvalidInput)
      )
    end

    it 'works' do
      params = { name: 'moo', public_key: ssh_pub_key }
      stub_create(:ssh_key, params)

      key = client.ssh_keys.create(**params)
      expect(key).to be_a described_class
      expect(key.id).to be_a Integer
      expect(key.name).to eq('moo')
      expect(key.public_key).to eq(ssh_pub_key)
      expect(key.fingerprint).to be_a String
      expect(key.created).to be_a Time
    end

    it 'validates uniq name' do
      stub_error(:ssh_keys, :post, 'uniqueness_error', 409)

      expect { client.ssh_keys.create(name: 'moo', public_key: ssh_pub_key) }.to(
        raise_error(Hcloud::Error::UniquenessError)
      )
    end
  end
end
