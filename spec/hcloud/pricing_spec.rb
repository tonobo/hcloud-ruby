# frozen_string_literal: true

require 'spec_helper'

describe Hcloud::Pricing, doubles: :pricing do
  include_context 'test doubles'

  let(:pricing) { new_pricing }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  it 'fetches pricing overview' do
    stub('pricing') do |_req, _info|
      {
        body: pricing,
        code: 200
      }
    end

    pricing = client.pricings.fetch
    expect(pricing.currency).to be_a String
    expect(pricing.image[:price_per_gb_month][:gross]).to be_a String
    expect(pricing.image[:price_per_gb_month][:net]).to be_a String
  end
end
