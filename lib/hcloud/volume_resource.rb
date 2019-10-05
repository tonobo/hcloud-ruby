# frozen_string_literal: true

module Hcloud
  class VolumeResource < AbstractResource
    include Enumerable

    def all
      mj('volumes') do |j|
        j.flat_map { |x| x['volumes'].map { |y| Volume.new(y, self, client) } }
      end
    end

    def create(size:, name:, automount: nil, format: nil, location: nil, server: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      j = Oj.load(request('volumes', j: query, code: 200).run.body)
      [
        j.key?('action') ? Action.new(j['action'], self, client) : nil,
        Volume.new(j['volume'], self, client)
      ]
    end

    def find(id)
      Volume.new(
        Oj.load(request("volumes/#{id}").run.body)['volume'],
        self,
        client
      )
    end

    def [](arg)
      case arg
      when Integer
        begin
          find(arg)
        rescue Error::NotFound
        end
      when String
        find_by(name: arg)
      end
    end

    def find_by(name:)
      x = Oj.load(request('volumes', q: { name: name }).run.body)['volumes']
      return nil if x.none?

      x.each do |v|
        return Volume.new(v, self, client)
      end
    end
  end
end
