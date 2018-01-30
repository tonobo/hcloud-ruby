require 'grape'

require_relative './fake_service/datacenter'
require_relative './fake_service/base'

require 'rspec'
require 'webmock/rspec'
require 'hcloud'

RSpec.configure do |c|
  c.before(:each) do
    stub_request(:any, /api.hetzner.cloud/).to_rack(Hcloud::FakeService::Base)
  end
end


