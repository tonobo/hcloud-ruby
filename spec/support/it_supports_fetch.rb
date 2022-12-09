# frozen_string_literal: true

RSpec.shared_examples 'it_supports_fetch' do |resource|
  source_url = resource.resource_class.name.demodulize.tableize

  it 'fetch items' do
    stub_collection(source_url, send(source_url))
    expect(client.send(source_url).count).to be_positive
  end
end
