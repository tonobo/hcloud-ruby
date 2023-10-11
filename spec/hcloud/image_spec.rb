# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'
require 'support/it_supports_update'
require 'support/it_supports_destroy'
require 'support/it_supports_labels_on_update'
require 'support/it_supports_action_fetch'

describe Hcloud::Image, doubles: :image do
  let :images do
    Array.new(Faker::Number.within(range: 20..150)).map { new_image }
  end

  let(:image) { images.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, \
                   %i[type status bound_to include_deprecated name label_selector]
  include_examples 'it_supports_find_by_id_and_name', described_class
  include_examples 'it_supports_update', described_class, { description: 'new description' }
  include_examples 'it_supports_destroy', described_class
  include_examples 'it_supports_labels_on_update', described_class
  include_examples 'it_supports_action_fetch', described_class

  it '#to_snapshot' do
    expectation = stub_update(:image, image, { type: 'snapshot' })
    stub_item(:images, image)

    client.images[image[:id]].to_snapshot

    expect(expectation.times_called).to eq(1)
  end
end
