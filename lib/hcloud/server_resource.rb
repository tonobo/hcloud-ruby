module Hcloud
  class ServerResource < AbstractResource
    include Enumerable

    def create(name:,
               server_type:,
               datacenter: nil,
               location: nil,
               start_after_create: nil,
               image:,
               ssh_keys: [],
               user_data: nil)
      query = {}
      method(:create).parameters.inject(query) do |r,x| 
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      Server.new(
        Oj.load(request("servers", j: query, code: 200).run.body)["server"],
        self,
        client
      )
    end

    def all
      Oj.load(request("servers").run.body)["servers"].map do |x|
        Server.new(x, self, client)
      end
    end

    def find(id)
      Server.new(
        Oj.load(request("servers/#{id.to_i}").run.body)["server"], self, client
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
      x = Oj.load(request("servers", q: {name: name}).run.body)["servers"]
      return nil if x.none?
      x.each do |s|
        return Server.new(s, self, client)
      end
    end
  end
end
