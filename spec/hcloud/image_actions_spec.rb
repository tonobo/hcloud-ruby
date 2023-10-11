# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Image, doubles: :image do
  include_context 'test doubles'
  include_context 'action tests'

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
      test_action(:change_protection, params: { delete: true })
    end
  end
end
