# frozen_string_literal: true

RSpec.shared_examples 'it_supports_labels_on_update' do |resource_type|
  source_url = resource_type.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context 'label support' do
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
