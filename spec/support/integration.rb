# frozen_string_literal: true

RSpec.shared_context 'integration auth' do
  # Some tests require a server or other resource other from the tested resource type.
  # We provide such resources as "helper".
  let(:helper_name) { resource_name('helper') }

  let :nonexistent_name do
    # just some randomly generated UUID
    '9e6c837e-b075-43c2-a7cb-44fd4bd8bc32'
  end

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
    # use a random ID to allow multiple CI runs in parallel
    $random_resource_name_id ||= Random.rand(10_000..99_999)
    "hcloud-ruby-integration-#{$random_resource_name_id}-#{name}"
  end

  def wait_for_action(resource, action_id)
    sleep 1 until resource.actions[action_id].status == 'success'
  end
end
