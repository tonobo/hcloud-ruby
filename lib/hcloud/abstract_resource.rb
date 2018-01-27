module Hcloud
  class AbstractResource
    attr_reader :client
    def initialize(client:)
      @client = client
    end

    protected

    def request(*args)
      client.request(*args)
    end
  end
end
