module Hcloud
  class AbstractResource
    attr_reader :client, :parent, :base_path

    def initialize(client:, parent: nil, base_path: "")
      @client = client
      @parent = parent
      @page = 1
      @per_page = 25
      @order = []
      @base_path = base_path
    end

    def page(page)
      @page = page
      self
    end

    def per_page(per_page)
      @per_page = per_page
      self
    end

    def order(*sort)
      @order = sort.flat_map do |s|
        case s
        when Symbol, String then s.to_s
        when Hash then s.map { |k, v| "#{k}:#{v}" }
        else
          raise ArgumentError, 
            "Unable to resolve type for given #{s.inspect} from #{sort}"
        end
      end
      self
    end
    
    def mj(path, **o, &block)
      m = MultiReply.new(j: Oj.load(request(path, o.merge(ep: ep)).run.body))
      m.cb = block
      m
    end
    
    def each(&block)
      all.each do |member|
        block.call(member)
      end
    end

    protected

    def page_params
      { per_page: @per_page, page: @page }.to_param
    end

    def sort_params
      @order.to_a.map{|x| "sort=#{x}" }.join("&")
    end

    def ep
      r = []
      (x = page_params).empty? ? nil : r << x 
      (x = sort_params).empty? ? nil : r << x
      r.compact.join("&")
    end

    def request(*args)
      client.request(*args)
    end
  end
end
