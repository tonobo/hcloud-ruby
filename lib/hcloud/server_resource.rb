# frozen_string_literal: true

module Hcloud
  class ServerResource < AbstractResource
    def create(name:,
               server_type:,
               datacenter: nil,
               location: nil,
               start_after_create: nil,
               image:,
               ssh_keys: [],
               networks: [],
               user_data: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      j = Oj.load(request('servers', j: query, code: 201).run.body)
      [
        Action.new(j['action'], self, client),
        Server.new(j['server'], self, client),
        j['root_password']
      ]
    end

    def all
      mj('servers') do |j|
        j.flat_map { |x| x['servers'].map { |x| Server.new(x, self, client) } }
      end
    end

    def find(id)
      Server.new(
        Oj.load(request("servers/#{id.to_i}").run.body)['server'], self, client
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
      x = Oj.load(request('servers', q: { name: name }).run.body)['servers']
      return nil if x.none?

      x.each do |s|
        return Server.new(s, self, client)
      end
    end
  end
end
