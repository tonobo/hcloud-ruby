module Hcloud
  class ImageResource < AbstractResource
    def all
      mj("images") do |j|
        j.flat_map{|x| x["images"].map{ |x| Image.new(x, self, client) } }
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
      Image.new(
        Oj.load(request("images/#{id.to_i}").run.body)["image"],
        self,
        client
      )
    end
    
    def where(sort: nil, type: nil, bound_to: nil, name: nil)
      query = {}
      method(:where).parameters.inject(query) do |r,x| 
        (var = eval(x.last.to_s)).nil? ? r : r.merge!(x.last => var)
      end
      mj("images", q: query) do |j|
        j.flat_map{|x| x["images"].map{ |x| Image.new(x, self, client) } }
      end
    end

    def find_by(name:)
      j = Oj.load(request("images", q: {name: name}).run.body)["images"]
      return if j.none?
      j.each do |x|
        return Image.new(x, self, client)
      end
    end

  end
end
