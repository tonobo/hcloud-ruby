module Hcloud
  class ServerResource < AbstractResource
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
      j = Oj.load(request("servers", j: query, code: 200).run.body)
      [
        Action.new(j["action"], self, client),
        Server.new(j["server"], self, client),
        j["root_password"]
      ]
    end

    def all
      mj("servers") do |j|
        j.flat_map{|x| x["servers"].map{ |x| Server.new(x, self, client) } }
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
