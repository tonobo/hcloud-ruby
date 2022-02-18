RSpec.shared_examples 'it_supports_find_by_id_and_name' do |resource|
  source_url = resource.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context 'find' do
    before :each do
      stub_collection source_url, send(source_url)
    end

    context 'works' do
      it '#[] -> find by id' do
        ref = send(sample_resource)
        pg = client.send(source_url)[ref[:id]]

        expect(pg).to be_a resource
        expect(pg.name).to eq(ref[:name])
      end

      it '#[] -> find by name' do
        ref = send(sample_resource)
        pg = client.send(source_url)[ref[:name]]

        expect(pg).to be_a resource
        expect(pg.name).to eq(ref[:name])
      end

      it '#find_by -> find by id' do
        ref = send(sample_resource)
        pg = client.send(source_url).find_by(id: ref[:id])

        expect(pg).to be_a resource
        expect(pg.name).to eq(ref[:name])
      end

      it '#find_by -> find by name' do
        ref = send(sample_resource)
        pg = client.send(source_url).find_by(name: ref[:name])

        expect(pg).to be_a resource
        expect(pg.name).to eq(ref[:name])
      end

      it '#find_by -> find by name' do
        ref = send(sample_resource)
        pg = client.send(source_url).find(ref[:id])

        expect(pg).to be_a resource
        expect(pg.name).to eq(ref[:name])
      end
    end

    context 'handle non existent' do
      it '#[] -> find by id' do
        expect do
          client.send(source_url).find(0)
        end.to raise Hcloud::Error::NotFound
      end

      it '#[] -> find by name' do
        expect(client.send(source_url)[0]).to be_nil
      end

      it '#find_by -> find by id' do
        expect(client.send(source_url).find_by(id: 0)).to be_nil
      end

      it '#find_by -> find by name' do
        expect(client.send(source_url).find_by(name: 'a')).to be_nil
      end

      it '#find -> find by id' do
        expect do
          client.send(source_url).find(0)
        end.to raise Hcloud::Error::NotFound
      end
    end
  end
end
