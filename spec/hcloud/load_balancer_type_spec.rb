# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_find_by_id_and_name'

describe Hcloud::LoadBalancerType, doubles: :load_balancer_type do
  let :load_balancer_types do
    Array.new(Faker::Number.within(range: 5..20)).map { new_load_balancer_type }
  end

  let(:load_balancer_type) { load_balancer_types.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_find_by_id_and_name', described_class
end
