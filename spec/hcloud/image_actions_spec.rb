# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Image, doubles: :image do
  include_context 'test doubles'

  let :images do
    Array.new(Faker::Number.within(range: 20..150)).map { new_image }
  end

  let(:image) { images.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  let :image_obj do
    stub_item(:images, image)
    client.images[image[:id]]
  end

  context '#change_protection' do
    it 'works' do
      expectation = stub_action(:images, image[:id], :change_protection) do |req, _info|
        expect(req).to have_body_params(a_hash_including({ 'delete' => true }))

        {
          action: build_action_resp(
            :change_protection, :success,
            resources: [{ id: 42, type: 'image' }]
          )
        }
      end

      action = image_obj.change_protection(delete: true)
      expect(expectation.times_called).to eq(1)
      expect(action).to be_a(Hcloud::Action)
      expect(action.resources[0]['id']).to eq(42)
    end
  end
end
