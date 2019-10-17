# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hcloud::Action, doubles: :action do
  include_context 'test doubles'

  let :actions do
    Array.new(Faker::Number.within(range: 20..150)).map { new_action }
  end

  let(:action) { actions.first }

  it 'GET /actions' do
    stub_collection :actions, actions
    expect(Hcloud::Action.all.to_a.size).to eq(actions.size)
    expect(actions.map { |action| action[:id] }).to eq(Hcloud::Action.all.map(&:id))
  end

  it 'GET /actions?status=running' do
    stub_collection :actions, actions do |request, _page_info|
      expect(request.url).to include('status=running')
    end
    expect(Hcloud::Action.where(status: :running).map(&:id)).to(
      eq(actions.map { |x| x[:id] }.compact)
    )
  end

  it 'GET /actions/:id' do
    stub "actions/#{action[:id]}" do |_request, _page_info|
      {
        body: { action: action },
        code: 200
      }
    end

    expect(Hcloud::Action.find(action[:id])).to be_a Hcloud::Action
    action.each do |key, value|
      expect(Hcloud::Action.find(action[:id]).public_send(key)).to eq(non_sym(value))
    end
  end
end
