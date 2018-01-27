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

    def each(&block)
      all.each do |member|
        block.call(member)
      end
    end
    
  end
end
