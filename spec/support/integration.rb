# frozen_string_literal: true

RSpec.shared_context 'integration auth' do
  # Some tests require a server or other resource other from the tested resource type.
  # We provide such resources as "helper".
  let(:helper_name) { resource_name('helper') }

  before(:context, integration_helper: :server) do
    client = Hcloud::Client.new(token: ENV['HCLOUD_TOKEN'])
    action, * = client.servers.create(
      name: resource_name('helper'), server_type: 'cx21', image: 'ubuntu-22.04'
    )

    server = client.servers[resource_name('helper')]

    wait_for_action(server, action.id)
    sleep 1 while server.locked
  end

  after(:context, integration_helper: :server) do
    client = Hcloud::Client.new(token: ENV['HCLOUD_TOKEN'])
    client.servers[resource_name('helper')]&.destroy
  end

  let :client do
    Hcloud::Client.new(token: ENV['HCLOUD_TOKEN'])
  end

  def resource_name(name)
    "hcloud-ruby-integration-#{name}"
  end

  def wait_for_action(resource, action_id)
    sleep 1 until resource.actions[action_id].status == 'success'
  end
end
