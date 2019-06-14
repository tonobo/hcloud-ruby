module Hcloud
  class FloatingIP
    Attributes = {
      id: nil,
      description: nil,
      ip: nil,
      type: nil,
      dns_ptr: nil,
      server: nil,
      home_location: Location,
      blocked: nil,
      created: :time,
      protection: nil
    }.freeze
    include EntryLoader

    def update(description:)
      j = Oj.load(request("floating_ips/#{id.to_i}",
                          j: { description: description },
                          method: :put).run.body)
      FloatingIP.new(j['floating_ip'], self, client)
    end

    def assign(server:)
      action(request(base_path('actions/assign'),
                     j: { server: server }))[0]
    end

    def unassign
      action(request(base_path('actions/unassign'), method: :post))[0]
    end

    def change_dns_ptr(ip:, dns_ptr:)
      action(request(base_path('actions/change_dns_ptr'),
                     j: { ip: ip, dns_ptr: dns_ptr }))[0]
    end

    def change_protection(delete: nil)
      query = {}
      query['delete'] = delete unless delete.nil?
      action(request(base_path('actions/change_protection'), j: query))[0]
    end

    def actions
      ActionResource.new(client: client, parent: self, base_path: base_path)
    end

    def destroy
      request("floating_ips/#{id}", method: :delete).run.body
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
      return ["floating_ips/#{id}", ext].compact.join('/') unless id.nil?
      raise ResourcePathError, 'Unable to build resource path. Id is nil.'
    end
  end
end
