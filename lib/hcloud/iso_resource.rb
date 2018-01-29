module Hcloud
  class IsoResource < AbstractResource
    include Enumerable

    def all
      Oj.load(request("isos").run.body)["isos"].map do |x|
        Iso.new(x, self, client)
      end
    end

    def [](arg)
      find_by(name: arg)
    end

    def find_by(name:)
      j = Oj.load(request("isos", q: {name: name}).run.body)["isos"]
      return if j.none?
      j.each do |x|
        return Iso.new(x, self, client)
      end
    end

  end
end
