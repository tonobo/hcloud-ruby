
module Hcloud
  class ActionResource < AbstractResource
    include Enumerable

    def all
      mj(base_path("actions")) do |j|
        j.flat_map{|x| x["actions"].map{ |x| Action.new(x, self, client) } }
      end
    end

    def find(id)
      Action.new(
        Oj.load(request(base_path("actions/#{id.to_i}")).run.body)["action"], 
        self, 
        client
      )
    end

    def [](arg)
      find(arg)
    rescue Error::NotFound
    end

    def where(status: nil)
      mj(base_path("actions"), q: {status: status}) do |j|
        j.flat_map{|x| x["actions"].map{ |x| Action.new(x, self, client) }}
      end
    end

    private

    def base_path(ext)
      [@base_path, ext].reject(&:empty?).join('/')
    end

  end
end
