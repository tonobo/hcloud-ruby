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
      blocked: nil
    }.freeze
    include EntryLoader

    def update(description:)
      j = Oj.load(request("floating_ips/#{id.to_i}",
                          j: { description: description },
                          method: :put).run.body)
      FloatingIP.new(j['floating_ip'], self, client)
    end

    def assign(server:)
      j = Oj.load(request("floating_ips/#{id.to_i}/actions/assign",
                          j: { server: server }).run.body)
      Action.new(j['action'], self, client)
    end

    def unassign
      j = Oj.load(request("floating_ips/#{id.to_i}/actions/unassign",
                          method: :post).run.body)
      Action.new(j['action'], self, client)
    end

    def actions
      ActionResource.new(client: client, parent: self, base_path: "floating_ips/#{id.to_i}")
    end

    def destroy
      request("floating_ips/#{id}", method: :delete).run.body
      true
    end
  end
end
