# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Volume, doubles: :volume do
  let :volumes do
    Array.new(Faker::Number.within(range: 20..150)).map { new_volume }
  end

  let(:volume) { volumes.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :volume_obj do
    stub_item(:volumes, volume)
    client.volumes[volume[:id]]
  end

  context '#change_protection' do
    it 'works' do
      expectation = stub_action(:volumes, volume[:id], :change_protection) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'delete' => true }))

        {
          action: build_action_resp(
            :change_protection, :success,
            resources: [{ id: volume[:id], type: 'volume' }]
          )
        }
      end

      action = volume_obj.change_protection(delete: true)
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('change_protection')
      expect(action.resources[0]['id']).to eq(volume[:id])
    end
  end

  context '#attach' do
    it 'handles missing server' do
      expect do
        volume_obj.attach(server: nil)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'works' do
      expectation = stub_action(:volumes, volume[:id], :attach) do |req, _info|
        expect(req).to have_body_params(
          a_hash_including(
            { 'server' => 42, 'automount' => true }
          )
        )

        {
          action: build_action_resp(
            :attach_volume, :success,
            resources: [{ id: volume[:id], type: 'volume' }, { id: 42, type: 'server' }]
          )
        }
      end

      action = volume_obj.attach(server: 42, automount: true)
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('attach_volume')
      expect(action.resources.map { |res| res['id'] }).to include(42, volume[:id])
    end
  end

  context '#detach' do
    it 'works' do
      expectation = stub_action(:volumes, volume[:id], :detach) do |_req, _info|
        {
          action: build_action_resp(
            :detach_volume, :success,
            resources: [{ id: 42, type: 'server' }]
          )
        }
      end

      action = volume_obj.detach
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('detach_volume')
      expect(action.resources[0]['id']).to eq(42)
    end
  end

  context '#resize' do
    it 'handles missing size' do
      expect do
        volume_obj.resize(size: nil)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'does not allow downsize' do
      expect do
        volume_obj.resize(size: volume_obj.size - 1)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'works' do
      # make sure the new size is larger than old size
      new_size = volume[:size] + 10

      expectation = stub_action(:volumes, volume[:id], :resize) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'size' => new_size }))

        {
          action: build_action_resp(
            :resize_volume, :success,
            resources: [{ id: volume[:id], type: 'volume' }]
          )
        }
      end

      action = volume_obj.resize(size: new_size)
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.command).to eq('resize_volume')
      expect(action.resources[0]['id']).to eq(volume[:id])
    end
  end
end
