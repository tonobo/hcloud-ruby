# frozen_string_literal: true

require 'spec_helper'

describe Hcloud::Pricing, doubles: :pricing do
  include_context 'test doubles'

  let(:api_pricing) { new_pricing }

  let :client do
    stub('pricing') do |_req, _info|
      {
        body: api_pricing,
        code: 200
      }
    end

    Hcloud::Client.new(token: 'secure')
  end

  it 'fetches pricing overview' do
    expect(client.pricing).to have_attributes(
      currency: a_kind_of(String),
      floating_ips: a_kind_of(Hcloud::PriceMatrix),
      images: a_kind_of(Hcloud::PriceMatrix),
      load_balancer_types: a_kind_of(Hcloud::PriceMatrix),
      primary_ips: a_kind_of(Hcloud::PriceMatrix),
      server_types: a_kind_of(Hcloud::PriceMatrix),
      traffic: a_kind_of(Hcloud::PriceMatrix),
      volumes: a_kind_of(Hcloud::PriceMatrix)
    )
  end

  context 'cost estimation' do
    let(:pricing) { client.pricing }

    it 'can estimate floating IP cost' do
      type = api_pricing[:pricing][:floating_ips][0][:type]
      location = api_pricing[:pricing][:floating_ips][0][:prices][0][:location]

      expect(
        pricing.floating_ips.estimated_cost(
          location, type: type, months: 2
        )
      ).to be_a_kind_of(Numeric)
    end

    it 'can estimate image cost' do
      expect(pricing.images.estimated_cost('fsn1', size_gb: 100)).to be_a_kind_of(Numeric)
    end

    it 'can estimate load balancer cost' do
      name = api_pricing[:pricing][:load_balancer_types][0][:name]
      location = api_pricing[:pricing][:load_balancer_types][0][:prices][0][:location]

      expect(
        pricing.load_balancer_types.estimated_cost(
          location, name: name, runtime_hours: 3
        )
      ).to be_a_kind_of(Numeric)
    end

    it 'can estimate primary IP cost' do
      type = api_pricing[:pricing][:primary_ips][0][:type]
      location = api_pricing[:pricing][:primary_ips][0][:prices][0][:location]

      expect(
        pricing.primary_ips.estimated_cost(
          location, type: type, hours: 3
        )
      ).to be_a_kind_of(Numeric)
    end

    it 'can estimate server cost' do
      name = api_pricing[:pricing][:server_types][0][:name]
      location = api_pricing[:pricing][:server_types][0][:prices][0][:location]

      expect(
        pricing.server_types.estimated_cost(
          location, name: name, runtime_hours: 3
        )
      ).to be_a_kind_of(Numeric)
    end

    it 'can estimate traffic cost' do
      expect(pricing.traffic.estimated_cost('fsn1', traffic_tb: 5)).to be_a_kind_of(Numeric)
    end

    it 'can estimate volume cost' do
      expect(pricing.volumes.estimated_cost('fsn1', size_gb: 100)).to be_a_kind_of(Numeric)
    end
  end
end
