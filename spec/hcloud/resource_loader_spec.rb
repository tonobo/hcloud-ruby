# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hcloud::ResourceLoader, doubles: :helper do
  include_context 'test doubles'

  let :sample_location do
    new_location(name: 'fsn1')
  end

  it 'can handle time' do
    loader = Hcloud::ResourceLoader.new({ field: :time }, client: client)
    result = loader.load({ field: '2022-03-09T10:11:12Z' })
    expect(result[:field]).to be_a Time
    expect(result[:field]).to eq(Time.new(2022, 3, 9, 10, 11, 12, 'Z'))
  end

  context 'can handle EntryLoader classes' do
    it 'with eagerly loaded objects' do
      loader = Hcloud::ResourceLoader.new({ field: Hcloud::Location }, client: client)
      result = loader.load({ field: sample_location })
      expect(result[:field]).to be_a Hcloud::Location
    end

    it 'with lazily loaded objects' do
      stub_item(:locations, sample_location)

      loader = Hcloud::ResourceLoader.new({ field: Hcloud::Location }, client: client)
      result = loader.load({ field: sample_location[:id] })
      expect(result[:field]).to be_a Hcloud::Future
      expect(result[:field].name).to eq('fsn1')
    end
  end

  context 'can handle arrays' do
    it 'of time' do
      loader = Hcloud::ResourceLoader.new({ field: [:time] }, client: client)
      result = loader.load({ field: ['2022-03-09T10:11:12Z', '2022-03-12T17:13:16Z'] })
      expect(result[:field]).to all be_a Time
      expect(result[:field]).to eq(
        [
          Time.new(2022, 3, 9, 10, 11, 12, 'Z'),
          Time.new(2022, 3, 12, 17, 13, 16, 'Z')
        ]
      )
    end

    it 'of class' do
      loader = Hcloud::ResourceLoader.new({ field: [Hcloud::Location] }, client: client)
      result = loader.load({ field: [sample_location, sample_location] })
      expect(result[:field]).to all be_a Hcloud::Location
      expect(result[:field].count).to eq(2)
    end

    it 'by keeping value when data is not an array' do
      loader = Hcloud::ResourceLoader.new({ field: [Hcloud::Location] }, client: client)
      result = loader.load({ field: sample_location })
      expect(result[:field]).to be_a Hash
      expect(result.dig(:field, :name)).to eq('fsn1')
    end
  end

  it 'can handle nested hashes' do
    schema = {
      field1: Hcloud::Location,
      field2: {
        sub_field: [Hcloud::Location]
      }
    }
    data = {
      field1: sample_location,
      field2: {
        sub_field: [sample_location]
      },
      field3: 'data-without-schema'
    }

    loader = Hcloud::ResourceLoader.new(schema, client: client)
    result = loader.load(data)

    expect(result[:field1]).to be_a Hcloud::Location
    expect(result.dig(:field2, :sub_field)).to all be_a Hcloud::Location
    expect(result.dig(:field2, :sub_field).count).to eq(1)
    expect(result[:field3]).to eq('data-without-schema')
  end

  it 'can handle lists with nested structures' do
    schema = { field: [{ field: Hcloud::Location }] }
    data = {
      field: [
        { field: sample_location, other: 'data-without-schema' },
        { field: sample_location, other: 'more-data-without-schema' }
      ]
    }

    loader = Hcloud::ResourceLoader.new(schema, client: client)
    result = loader.load(data)

    expect(result[:field].map { |item| item[:field] }).to all be_a Hcloud::Location
    expect(result[:field].map { |item| item[:field] }.map(&:name)).to all eq('fsn1')
    expect(result[:field][0][:other]).to eq('data-without-schema')
    expect(result[:field][1][:other]).to eq('more-data-without-schema')
  end

  it 'can use an extractor' do
    stub_item(:locations, sample_location)

    schema = {
      field: lambda do |data, client|
        Hcloud::Future.new(client, Hcloud::Location, data[:id])
      end
    }
    data = {
      field: {
        id: sample_location[:id]
      }
    }

    loader = Hcloud::ResourceLoader.new(schema, client: client)
    result = loader.load(data)

    expect(result[:field]).to be_a(Hcloud::Future).and have_attributes(name: 'fsn1')
  end
end
