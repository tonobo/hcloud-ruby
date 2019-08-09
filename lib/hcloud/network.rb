# frozen_string_literal: true

module Hcloud
  class Network
    Attributes = {
      id: nil,
      name: nil,
      ip_range: nil,
      subnets: nil,
      routes: nil,
      servers: nil,
      protection: nil,
      created: :time
    }.freeze
    include EntryLoader

    def update(name:)
      j = Oj.load(request("networks/#{id.to_i}",
                          j: { name: name },
                          method: :put).run.body)
      Network.new(j['network'], self, client)
    end

    def add_subnet(type:, ip_range: nil, network_zone:)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/add_subnet'), j: query))[0]
    end

    def del_subnet(ip_range:)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/del_subnet'), j: query))[0]
    end

    def add_route(destination:, gateway:)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/add_route'), j: query))[0]
    end

    def del_route(destination:, gateway:)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/del_route'), j: query))[0]
    end

    def change_ip_range(ip_range:)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/change_ip_range'), j: query))[0]
    end

    def change_protection(delete: nil)
      query = COLLECT_ARGS.call(__method__, binding)
      action(request(base_path('actions/change_protection'), j: query))[0]
    end

    def actions
      ActionResource.new(client: client, parent: self, base_path: base_path)
    end

    def destroy
      request("networks/#{id}", method: :delete).run.body
      true
    end

    private

    def action(request)
      j = Oj.load(request.run.body)
      [
        Action.new(j['action'], parent, client),
        j
      ]
    end

    def base_path(ext = nil)
      return ["networks/#{id}", ext].compact.join('/') unless id.nil?

      raise ResourcePathError, 'Unable to build resource path. Id is nil.'
    end
  end
end
