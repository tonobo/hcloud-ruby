# frozen_string_literal: true

RSpec.shared_examples 'it_supports_destroy' do |resource|
  source_url = resource.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  it '#destroy' do
    resource = send(sample_resource)
    expectation = stub_delete(sample_resource, resource)
    stub_collection(source_url, send(source_url))

    expect(client.send(source_url).find(resource[:id]).destroy).to be_a described_class

    expect(expectation.times_called).to eq(1)
  end
end
