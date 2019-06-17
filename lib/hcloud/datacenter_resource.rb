# frozen_string_literal: true

module Hcloud
  class DatacenterResource < AbstractResource
    include Enumerable

    def all
      j = Oj.load(request('datacenters').run.body)
      dc = j['datacenters'].map { |x| Datacenter.new(x, self, client) }
      dc.reject { |x| x.id == j['recommendation'] }.unshift(
        dc.find { |x| x.id == j['recommendation'] }
      )
    end

    def recommended
      all.first
    end

    def find(id)
      Datacenter.new(
        Oj.load(request("datacenters/#{id}").run.body)['datacenter'],
        self,
        client
      )
    end

    def find_by(name:)
      x = Oj.load(request('datacenters', q: { name: name }).run.body)['datacenters']
      return nil if x.none?

      x.each do |s|
        return Datacenter.new(s, self, client)
      end
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
  end
end
