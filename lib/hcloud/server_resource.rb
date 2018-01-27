module Hcloud
  class ServerResource < AbstractResource
    include Enumerable

    def all
      Oj.load(request("servers").run.body)["servers"].map do |x|
        Server.new(x)
      end
    end

    def each(&block)
      all.each do |member|
        block.call(member)
      end
    end
    
  end
end
