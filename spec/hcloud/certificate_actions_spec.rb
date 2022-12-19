# frozen_string_literal: true

require 'active_support/all'
require 'spec_helper'

describe Hcloud::Certificate, doubles: :certificate do
  include_context 'test doubles'

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
      stub_action(:certificates, certificate[:id], :retry) do |_req, _info|
        {
          action: build_action_resp(
            :issue_certificate, :running,
            resources: [{ id: 42, type: 'certificate' }]
          )
        }
      end

      action = certificate_obj.retry
      expect(action).to be_a Hcloud::Action
      expect(action.command).to eq('issue_certificate')
    end
  end
end
