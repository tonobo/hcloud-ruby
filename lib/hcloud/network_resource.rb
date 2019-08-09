# frozen_string_literal: true

module Hcloud
  class NetworkResource < AbstractResource
    include Enumerable

    def all
      mj('networks') do |j|
        j.flat_map { |x| x['networks'].map { |y| Network.new(y, self, client) } }
      end
    end

    def create(name:, ip_range:, subnets: nil, routes: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      j = Oj.load(request('networks', j: query, code: 201).run.body)
      [
        j.key?('action') ? Action.new(j['action'], self, client) : nil,
        Network.new(j['network'], self, client)
      ]
    end

    def find(id)
      Network.new(
        Oj.load(request("networks/#{id}").run.body)['network'],
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
      x = Oj.load(request('networks', q: { name: name }).run.body)['networks']
      return nil if x.none?

      x.each do |v|
        return Network.new(v, self, client)
      end
    end
  end
end
