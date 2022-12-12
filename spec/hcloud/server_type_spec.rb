# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'

describe Hcloud::ServerType, doubles: :server_type do
  include_context 'test doubles'

  let :server_types do
    Array.new(Faker::Number.within(range: 20..150)).map { new_server_type }
  end

  let(:server_type) { server_types.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
end
