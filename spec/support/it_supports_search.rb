# frozen_string_literal: true

RSpec.shared_examples 'it_supports_search' do |resource, filter_attributes|
  source_url = resource.resource_class.name.demodulize.tableize

  context '#where' do
    filter_attributes.to_a.each do |filter|
      context "with filter for \"#{filter}\"" do
        it 'works' do
          search_term = 'search_term'
          expectation = stub(source_url) do |req, _info|
            expect(req).to have_query_params(
              a_hash_including({ filter => search_term }.deep_stringify_keys)
            )

            items = send(source_url)
            {
              body: {
                source_url.to_sym => items
              }.merge(pagination(items)),
              code: 200
            }
          end

          items = client.send(source_url).where({ filter => search_term })
          expect(items.count).to be_positive
          expect(items).to all be_a resource

          # might be called multiple times due to pagination
          expect(expectation.times_called).to be > 0
        end
      end
    end
  end
end
