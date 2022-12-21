# frozen_string_literal: true

require 'hcloud/errors'
require 'hcloud/price_matrix'
require 'faker'

RSpec.describe Hcloud::PriceMatrix do
  def time_price
    {
      price_hourly: {
        gross: Faker::Number.decimal,
        net: Faker::Number.decimal
      },
      price_monthly: {
        gross: Faker::Number.decimal,
        net: Faker::Number.decimal
      }
    }
  end

  let :matrix do
    prices = [{
      id: Faker::Number.number,
      name: 'cx11',
      location: 'fsn1',
      prices: time_price
    }, {
      id: Faker::Number.number,
      name: 'cx11',
      location: 'nbg1',
      prices: time_price
    }, {
      id: Faker::Number.number,
      name: 'cx21',
      location: 'fsn1',
      prices: time_price
    }, {
      id: Faker::Number.number,
      name: 'cx21',
      location: 'hel1',
      prices: time_price
    }]
    Hcloud::PriceMatrix.new(prices, :server_type)
  end

  context 'with invalid input' do
    it 'detects missing prices' do
      prices = [{
        name: 'cx11',
        price_monthly: {
          net: Faker::Number.number,
          gross: Faker::Number.number
        }
      }]
      expect { Hcloud::PriceMatrix.new(prices, :server_type) }.to(
        raise_error Hcloud::Error::InvalidInput
      )
    end

    it 'detects missing net price' do
      prices = [{
        name: 'cx11',
        prices: {
          price_monthly: {
            gross: Faker::Number.number
          }
        }
      }]
      expect { Hcloud::PriceMatrix.new(prices, :server_type) }.to(
        raise_error Hcloud::Error::InvalidInput
      )
    end
  end

  it 'can be iterated' do
    expect(matrix).to respond_to(:each)
  end

  context '#filter' do
    let :filtered do
      matrix.filter(name: 'cx11')
    end

    it 'returns a price matrix' do
      expect(filtered).to be_a(Hcloud::PriceMatrix)
    end

    it 'contains only filtered items' do
      expect(filtered).to all(satisfy { |item| item[:name] == 'cx11' })
    end
  end

  context '#estimate_cost' do
    it 'raises on too few filters' do
      expect do
        # without a name we do not know for which server type the price should be estimated
        matrix.estimated_cost('fsn1', runtime_hours: 'bar')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'raises on invalid attribute' do
      expect do
        matrix.estimated_cost('fsn1', name: 'cx11', foo: 'bar')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'raises on missing calculation attributes' do
      expect do
        # without a runtime we do not know for how many hours we should estimate
        matrix.estimated_cost('fsn1', name: 'cx11')
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'can estimate cost' do
      cost = matrix.estimated_cost('fsn1', name: 'cx11', runtime_hours: 100)
      expect(cost).to be_a_kind_of(Numeric)
    end

    it 'can handle wildcard location' do
      # Some prices are announced as the same price in all regions.
      # In PriceMatrix we omit the location entry for those prices.
      # The user # still has to specify it, because (to be future-proof) we always require
      # a location to be specified.
      prices = [{
        prices: {
          price_per_gb_month: {
            net: Faker::Number.number,
            gross: Faker::Number.number
          }
        }
      }]
      matrix = Hcloud::PriceMatrix.new(prices, :volume)

      expect(matrix.estimated_cost('fsn1', size_gb: 100)).to be_a_kind_of(Numeric)
    end
  end
end
