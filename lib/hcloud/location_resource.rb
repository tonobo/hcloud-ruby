# frozen_string_literal: true

module Hcloud
  class LocationResource < AbstractResource
    def all
      mj('locations') do |j|
        j.flat_map { |x| x['locations'].map { |x| Location.new(x, self, client) } }
      end
    end

    def find(id)
      Location.new(
        Oj.load(request("locations/#{id}").run.body)['location'],
        self,
        client
      )
    end

    def find_by(name:)
      x = Oj.load(request('locations', q: { name: name }).run.body)['locations']
      return nil if x.none?

      x.each do |s|
        return Location.new(s, self, client)
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
