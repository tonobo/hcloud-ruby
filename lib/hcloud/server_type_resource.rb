# frozen_string_literal: true

module Hcloud
  class ServerTypeResource < AbstractResource
    include Enumerable

    def all
      j = Oj.load(request('server_types').run.body)
      j['server_types'].map { |x| ServerType.new(x, self, client) }
    end

    def find(id)
      ServerType.new(
        Oj.load(request("server_types/#{id}").run.body)['server_type'],
        self,
        client
      )
    end

    def find_by(name:)
      x = Oj.load(request('server_types', q: { name: name }).run.body)['server_types']
      return nil if x.none?

      x.each do |s|
        return ServerType.new(s, self, client)
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
