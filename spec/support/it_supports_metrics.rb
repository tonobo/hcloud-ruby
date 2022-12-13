# frozen_string_literal: true

require 'faker'

RSpec.shared_examples 'it_supports_metrics' do |resource, metrics|
  source_url = resource.resource_class.name.demodulize.tableize
  sample_resource = source_url.gsub(/s$/, '')

  context '#metrics' do
    let :sample do
      send(sample_resource)
    end

    let :sample_obj do
      stub_item(source_url, sample)
      client.send(source_url)[sample[:id]]
    end

    def build_metrics(params)
      step = params[:step] || Faker::Number.within(range: 1..60)
      start = DateTime.iso8601(params[:start]).strftime('%s').to_i

      {
        start: params[:start],
        end: params[:end],
        step: step,
        time_series: {
          params[:type].to_sym => {
            # generate a random length list of a few random values
            values: Array.new(Faker::Number.within(range: 0..100)).map.with_index do |_, idx|
              [start + idx * step, Faker::Number.decimal.to_s]
            end
          }
        }
      }
    end

    it 'handles missing type' do
      expect do
        sample_obj.metrics(type: nil, start: Time.now, end: Time.now + 60)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing start' do
      expect do
        sample_obj.metrics(type: :open_connections, start: nil, end: Time.now + 60)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles missing end' do
      expect do
        sample_obj.metrics(type: :open_connections, start: Time.now, end: nil)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    it 'handles end before start' do
      expect do
        sample_obj.metrics(type: :open_connections, start: Time.now, end: Time.now - 60)
      end.to raise_error Hcloud::Error::InvalidInput
    end

    metrics.each do |metric|
      it "can fetch metric \"#{metric}\"" do
        expectation = stub("#{source_url}/#{sample[:id]}/metrics") do |req, _info|
          # required parameters for calls to metrics endpoint
          expect(req.options[:params]).to have_key(:type)
          expect(req.options[:params]).to have_key(:start)
          expect(req.options[:params]).to have_key(:end)

          # start and end must be in ISO-8601 format
          expect { DateTime.iso8601(req.options[:params][:start]) }.not_to raise_error
          expect { DateTime.iso8601(req.options[:params][:end]) }.not_to raise_error

          {
            body: {
              metrics: build_metrics(req.options[:params])
            },
            code: 200
          }
        end

        expect(sample_obj).to be_a resource
        result = sample_obj.metrics(
          type: metric,
          start: Time.now - 7 * 24 * 60 * 60,
          end: Time.now,
          step: 5
        )

        expect(expectation.times_called).to eq(1)
        expect(result[:time_series]).to have_key(metric)

        # access is possible both with symbol and string
        expect(result[:time_series][metric.to_sym][:values]).to be_a Array
        expect(result['time_series'][metric.to_s]['values']).to be_a Array

        expect(result[:time_series][metric][:values].all? do |contents|
          # time + value must be exactly two values
          contents.count == 2
        end).to be true
      end
    end
  end
end
