# frozen_string_literal: true

RSpec.shared_context 'action tests' do
  def resources_name
    described_class.resource_class.name.demodulize.tableize
  end

  def resource_name
    resources_name.gsub(/s$/, '')
  end

  def generate_resources(other_resources)
    # An action has a field "resources" that gets populated with the types
    # and IDs of all affected resources. Often this is only the main resource
    # on which the action is executed, but sometimes multiple resources can
    # be affected, e.g. when a firewall (primary resource) gets attached to
    # a server (other resource).
    resources = other_resources.to_a.map do |resource_name|
      { id: 42, type: resource_name.to_s }
    end
    resources << { id: send(resource_name)[:id], type: resource_name }

    resources
  end

  def test_action(action, command = nil, params: nil, additional_resources: nil)
    command ||= action

    stub = stub_action(resources_name.to_sym, send(resource_name)[:id], action) do |req, _info|
      unless params.nil?
        expect(req).to have_body_params(a_hash_including(params.deep_stringify_keys))
      end

      {
        action: build_action_resp(
          command,
          :running,
          resources: generate_resources(additional_resources)
        )
      }
    end

    action = send("#{resource_name}_obj").send(action, **params.to_h)

    expect(stub.times_called).to eq(1)
    expect(action).to be_a(Hcloud::Action)
    expect(action.command).to eq(command.to_s)
  end
end
