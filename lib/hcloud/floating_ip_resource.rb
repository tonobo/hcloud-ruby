module Hcloud
  class FloatingIPResource < AbstractResource
    include Enumerable

    def all
      j = Oj.load(request("floating_ips").run.body)
      j["floating_ips"].map{|x| FloatingIP.new(x, self, client) }
    end

    def create(type:, server: nil, home_location: nil, description: nil)
      query = {}
      method(:create).parameters.inject(query) do |r,x| 
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      j = Oj.load(request("floating_ips", j: query, code: 200).run.body)
      [
        Action.new(j["action"], self, client),
        FloatingIP.new(j["floating_ip"], self, client),
      ]
    end

    def find(id)
      FloatingIP.new(
        Oj.load(request("floating_ips/#{id}").run.body)["floating_ip"],
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
      end
    end

  end
end
