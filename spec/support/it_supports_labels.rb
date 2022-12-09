# frozen_string_literal: true

RSpec.shared_examples 'it_supports_labels' do |resource_type, create_params|
  source_url = resource_type.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context 'label support' do
    it '#create with labels' do
      labels = { 'key' => 'value', 'novalue' => '' }

      expectation = stub_create(sample_resource, create_params.merge({ labels: labels }))

      created_item = client.send(source_url).create(**create_params, labels: labels)

      expect(created_item).to be_a resource_type
      expect(created_item.labels).to eq(labels)
      expect(expectation.times_called).to eq(1)
    end

    it '#update labels' do
      new_labels = { 'key' => 'value', 'novalue' => '' }
      sample = send(sample_resource)
      expectation = stub_update(sample_resource, sample, { labels: new_labels })
      stub_collection(source_url, send(source_url))

      updated_item = client.send(source_url).find(sample[:id]).update(labels: new_labels)
      expect(updated_item).to be_a resource_type
      expect(updated_item.labels).to eq(new_labels)
      expect(expectation.times_called).to eq(1)
    end
  end
end
