# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'

describe Hcloud::Datacenter, doubles: :datacenter do
  include_context 'test doubles'

  let :datacenters do
    Array.new(Faker::Number.within(range: 20..150)).map { new_datacenter }
  end

  let(:datacenter) { datacenters.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name]
  include_examples 'it_supports_find_by_id_and_name', described_class

  it '#recommended' do
    # using skip instead of pending, because due to randomness sometimes
    # this test will work successfully
    skip 'currently does not take into account the recommendation from the API'

    stub(:datacenters) do |_req, _info|
      {
        body: {
          datacenters: datacenters,
          recommendation: datacenter[:id]
        },
        code: 200
      }
    end

    expect(client.datacenters.recommended).to be_a Hcloud::Datacenter
    expect(client.datacenters.recommended.id).to eq(datacenter[:id])
  end
end
