# frozen_string_literal: true

RSpec.shared_examples 'it_supports_update' do |resource_type, update_params|
  source_url = resource_type.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context '#update' do
    # Test update of all attributes at once
    it 'update all attributes' do
      sample = send(sample_resource)
      expectation = stub_update(sample_resource, sample, update_params)
      stub_collection(source_url, send(source_url))

      updated_item = client.send(source_url).find(sample[:id]).update(**update_params)
      expect(expectation.times_called).to eq(1)

      expect(updated_item).to be_a resource_type
      update_params.each do |key, value|
        expect(updated_item.send(key)).to eq(value)
      end
    end

    # Test update of each attribute individually
    update_params.each do |key, value|
      it "update attribute \"#{key}\"" do
        sample = send(sample_resource)
        expectation = stub_update(sample_resource, sample, { key => value })
        stub_collection(source_url, send(source_url))

        updated_item = client.send(source_url).find(sample[:id]).update(**{ key => value })
        expect(updated_item).to be_a resource_type
        expect(updated_item.send(key)).to eq(value)
        expect(expectation.times_called).to eq(1)
      end
    end
  end
end
