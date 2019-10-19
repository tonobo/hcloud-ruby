# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Hcloud::Action, doubles: :action do
  include_context 'test doubles'

  let :actions do
    Array.new(Faker::Number.within(range: 20..150)).map { new_action }
  end

  let(:action) { actions.first }

  context 'client - pagination' do
    def run_query
      client = Hcloud::Client.connection

      random_choice(true, false) ? client.actions.to_a : Hcloud::Action.all.to_a
    end

    it 'checks auto pagination' do
      actions = Array.new(Faker::Number.within(range: 100..150)).map { new_action }
      pages = []
      page_count = []
      stub_collection(:actions, actions) do |request, _page_info|
        page_count << request.url[/per_page=(\d+)/, 1]
        pages << request.url[/[^_]page=(\d+)/, 1]
      end
      run_query
      expect(pages).to eq(%w[1 1 2 3])
      expect(page_count).to eq(%w[1 50 50 50])
    end

    it 'stops on single action' do
      pages = []
      page_count = []
      stub_collection(:actions, [new_action]) do |request, _page_info|
        page_count << request.url[/per_page=(\d+)/, 1]
        pages << request.url[/[^_]page=(\d+)/, 1]
      end
      run_query
      expect(pages).to eq(%w[1])
      expect(page_count).to eq(%w[1])
    end

    it "won't break on empty result set" do
      pages = []
      page_count = []
      stub_collection(:actions, []) do |request, _page_info|
        page_count << request.url[/per_page=(\d+)/, 1]
        pages << request.url[/[^_]page=(\d+)/, 1]
      end
      run_query
      expect(pages).to eq(%w[1])
      expect(page_count).to eq(%w[1])
    end

    it 'queries actions manually and concurrently' do
      actions = Array.new(Faker::Number.within(range: 100..150)).map { new_action }
      pages = []
      page_count = []
      client = Hcloud::Client.new(token: 'moo')
      stub_collection(:actions, actions) do |request, _page_info|
        expect(request.hydra).to eq(client.hydra)
        page_count << request.url[/per_page=(\d+)/, 1]
        pages << request.url[/[^_]page=(\d+)/, 1]
      end
      fetched_actions = client.concurrent do
        [
          client.actions.page(1).per_page(50),
          client.actions.page(2).per_page(50),
          client.actions.page(5).per_page(25),
          client.actions.page(6).per_page(25)
        ]
      end
      expect(fetched_actions.flat_map(&:to_a).map(&:id)).to eq(actions.map { |x| x[:id] })
      expect(pages).to eq(%w[1 2 5 6])
      expect(page_count).to eq(%w[50 50 25 25])
    end
  end

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
