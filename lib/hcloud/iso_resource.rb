module Hcloud
  class IsoResource < AbstractResource
    def all
      mj('isos') do |j|
        j.flat_map { |x| x['isos'].map { |x| Iso.new(x, self, client) } }
      end
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

    def find(id)
      Iso.new(
        Oj.load(request("isos/#{id.to_i}").run.body)['iso'],
        self,
        client
      )
    end

    def find_by(name:)
      j = Oj.load(request('isos', q: { name: name }).run.body)['isos']
      return if j.none?
      j.each do |x|
        return Iso.new(x, self, client)
      end
    end
  end
end
