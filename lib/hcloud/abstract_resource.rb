module Hcloud
  class AbstractResource
    attr_reader :client, :parent, :base_path

    def initialize(client:, parent: nil, base_path: "")
      @client = client
      @parent = parent
      @base_path = base_path
    end
    
    def each(&block)
      all.each do |member|
        block.call(member)
      end
    end

    protected

    def request(*args)
      client.request(*args)
    end
  end
end
