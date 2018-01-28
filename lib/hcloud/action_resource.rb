
module Hcloud
  class ActionResource < AbstractResource
    include Enumerable

    def all
      Oj.load(request(base_path + "/actions").run.body)["actions"].map do |x|
        Action.new(x, self, client)
      end
    end

  end
end
