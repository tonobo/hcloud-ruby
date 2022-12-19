# frozen_string_literal: true

require 'spec_helper'
require 'support/it_supports_fetch'
require 'support/it_supports_search'
require 'support/it_supports_find_by_id_and_name'

describe Hcloud::Location, doubles: :location do
  include_context 'test doubles'

  let :locations do
    Array.new(Faker::Number.within(range: 20..150)).map { new_location }
  end

  let(:location) { locations.sample }

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  include_examples 'it_supports_fetch', described_class
  include_examples 'it_supports_search', described_class, %i[name]
  include_examples 'it_supports_find_by_id_and_name', described_class
end
