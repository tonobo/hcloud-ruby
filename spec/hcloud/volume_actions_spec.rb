# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Volume, doubles: :volume do
  include_context 'test doubles'
  include_context 'action tests'

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
      test_action(:change_protection, params: { delete: true })
    end
  end

  context '#attach' do
    it 'handles missing server' do
      expect do
        volume_obj.attach(server: nil)
      end.to raise_error(Hcloud::Error::InvalidInput)
    end

    it 'works' do
      test_action(
        :attach,
        :attach_volume,
        params: { server: 42, automount: true },
        additional_resources: %i[server]
      )
    end
  end

  context '#detach' do
    it 'works' do
      test_action(
        :detach,
        :detach_volume,
        additional_resources: %i[server]
      )
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

      test_action(:resize, :resize_volume, params: { size: new_size })
    end
  end
end
