# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Certificate, doubles: :certificate do
  include_context 'test doubles'
  include_context 'action tests'

  let :certificates do
    Array.new(Faker::Number.within(range: 10..50)).map { new_certificate }
  end

  let(:certificate) { certificates.sample }

  let :certificate_obj do
    stub_item(:certificates, certificate)
    client.certificates[certificate[:id]]
  end

  let :client do
    Hcloud::Client.new(token: 'secure')
  end

  context '#retry' do
    it 'works' do
      test_action(:retry, :issue_certificate)
    end
  end
end
