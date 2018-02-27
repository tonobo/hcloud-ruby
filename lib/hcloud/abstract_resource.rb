module Hcloud
  class AbstractResource
    include Enumerable

    attr_reader :client, :parent, :base_path

    def initialize(client:, parent: nil, base_path: '')
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

    def limit(limit)
      @limit = limit
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
      if !client.nil? && client.auto_pagination
        requests = __entries__(path, **o)
        if requests.all? { |x| x.is_a? Hash }
          m = MultiReply.new(j: requests, pagination: :auto)
          m.cb = block
          return m
        end
        client.hydra.run
        j = requests.map do |x|
          Oj.load(x.response.body)
        end
        m = MultiReply.new(j: j, pagination: :auto)
        m.cb = block
        return m
      end
      m = MultiReply.new(j: [Oj.load(request(path, o.merge(ep: ep)).run.body)])
      m.cb = block
      m
    end

    def each
      all.each do |member|
        yield(member)
      end
    end

    protected

    def page_params(per_page: nil, page: nil)
      { per_page: per_page || @per_page, page: page || @page }.to_param
    end

    def sort_params
      @order.to_a.map { |x| "sort=#{x}" }.join('&')
    end

    def ep(per_page: nil, page: nil)
      r = []
      (x = page_params(per_page: per_page, page: page)).empty? ? nil : r << x
      (x = sort_params).empty? ? nil : r << x
      r.compact.join('&')
    end

    def request(*args)
      client.request(*args)
    end

    def __entries__(path, **o)
      ret = Oj.load(request(path, o.merge(ep: ep(per_page: 1, page: 1))).run.body)
      a = ret.dig('meta', 'pagination', 'total_entries').to_i
      return [ret] if a <= 1
      unless @limit.nil?
        a = @limit if a > @limit
      end
      r = a / Client::MAX_ENTRIES_PER_PAGE
      r += 1 if a % Client::MAX_ENTRIES_PER_PAGE > 0
      requests = r.times.map do |i|
        per_page = Client::MAX_ENTRIES_PER_PAGE
        if !@limit.nil? && (r == (i + 1)) && (a % per_page != 0)
          per_page = a % per_page
        end
        req = request(path, o.merge(ep: ep(per_page: per_page, page: i + 1)))
        client.hydra.queue req
        req
      end
    end
  end
end
