# frozen_string_literal: true

RSpec.shared_examples 'it_supports_action_fetch' do |resource|
  source_url = resource.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context 'Action' do
    let :actions do
      Array.new(Faker::Number.within(range: 5..10)).map { new_action }
    end

    let(:action) { actions.sample }

    let(:sample) { send(sample_resource) }

    it 'get all actions' do
      stub_item(source_url, sample)
      stub_collection("#{source_url}/#{sample[:id]}/actions", actions, resource_name: :actions)

      sample_obj = client.send(source_url)[sample[:id]]
      expect(sample_obj.actions.count).to be_positive
      expect(sample_obj.actions).to all be_a Hcloud::Action
      # check whether the action content is actually read correctly
      expect(sample_obj.actions.map(&:id)).to all be_positive
    end

    it 'get a single action' do
      stub_item(source_url, sample)
      stub_item(
        "#{source_url}/#{sample[:id]}/actions/#{action[:id]}",
        action,
        resource_name: :actions
      )

      sample_obj = client.send(source_url)[sample[:id]]
      got_action = sample_obj.actions[action[:id]]
      expect(got_action).to be_a Hcloud::Action
      expect(got_action.id).to eq(action[:id])
      expect(got_action.command).to eq(action[:command])
      expect(got_action.status).to eq(action[:status].to_s)
      expect(got_action.started).to eq(action[:started])
      expect(got_action.finished).to eq(action[:finished])
    end
  end
end
