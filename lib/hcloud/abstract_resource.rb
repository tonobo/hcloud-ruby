# frozen_string_literal: true

require 'active_support/core_ext/string'

module Hcloud
  class AbstractResource
    include Enumerable

    delegate :request, :prepare_request, to: :client

    class << self
      def bind_to(klass)
        resource = self
        %w[find find_by where all [] page limit per_page order
           to_a count pagnation each].each do |method|
          klass.define_singleton_method(method) do |*args, &block|
            resource.new(client: Client.connection).public_send(method, *args, &block)
          end
        end
      end

      def filter_attributes(*keys)
        return @filter_attributes if keys.to_a.empty?

        @filter_attributes = keys
      end

      def resource_class
        ancestors[ancestors.index(Hcloud::AbstractResource) - 1]
      end

      def resource_url(url = nil)
        return (@resource_url = url) if url

        @resource_url || resource_class.name.demodulize.gsub('Resource', '').tableize
      end

      def resource_path(path = nil)
        return (@resource_path = path) if path

        @resource_path || resource_url
      end

      def resource(res = nil)
        return (@resource = res) if res
        return @resource if @resource

        auto_const = resource_class.name.demodulize.gsub('Resource', '').to_sym
        return Hcloud.const_get(auto_const) if Hcloud.constants.include?(auto_const)

        raise Error, "unable to lookup resource class for #{name}"
      end
    end

    attr_reader :client

    def initialize(client:, base_path: '')
      @client = client
      @page = 1
      @per_page = 25
      @order = []
      @base_path = base_path
    end

    def all
      where
    end

    def where(**kwargs)
      kwargs.keys.each do |key|
        keys = self.class.filter_attributes.map(&:to_s)
        next if keys.include?(key.to_s)

        raise ArgumentError, "unknown filter #{key}, allowed keys are #{keys}"
      end

      _dup :@query, @query.to_h.merge(kwargs)
    end

    def find(id)
      prepare_request(
        [self.class.resource_url, id].join('/'),
        resource_path: resource_path.to_s.singularize,
        resource_class: self.class.resource
      )
    end

    def [](arg)
      find_by(id: arg)
    end

    def find_by(**kwargs)
      if id = kwargs.delete(:id)
        return find(id)
      end

      per_page(1).where(**kwargs).first
    rescue Error::NotFound
    end

    # def count
    #  per_page(1).first&.response&.pagination&.total_entries.to_i
    # end

    def page(page)
      _dup :@page, page
    end

    def per_page(per_page)
      _dup :@per_page, per_page
    end

    def limit(limit)
      _dup :@limit, limit
    end

    def order(*sort)
      _dup :@order,
           begin
           sort.flat_map do |s|
             case s
             when Symbol, String then s.to_s
             when Hash then s.map { |k, v| "#{k}:#{v}" }
             else
               raise ArgumentError,
                     "Unable to resolve type for given #{s.inspect} from #{sort}"
             end
           end
         end
    end

    def run
      @run ||= multi_query(
        resource_url,
        q: @query,
        resource_path: resource_path,
        resource_class: self.class.resource
      )
    end

    def each
      run.each do |member|
        yield(member)
      end
    end

    # this is just to keep the actual bevahior
    def pagination
      return :auto if client.auto_pagination

      run.response.pagination
    end

    protected

    def _dup(var, value)
      dup.tap do |res|
        res.instance_variable_set(var, value)
        res.instance_variable_set(:@run, nil)
      end
    end

    def resource_path
      self.class.resource_path || self.class.resource_url
    end

    def resource_url
      [@base_path.to_s, self.class.resource_url.to_s].reject(&:empty?).join('/')
    end

    def multi_query(path, **o)
      return prepare_request(path, o.merge(ep: ep)) unless client&.auto_pagination

      raise Error, 'unable to run auto paginate within concurrent excecution' if @concurrent

      requests = __entries__(path, **o)
      return requests.flat_map(&:resource) if requests.all? { |req| req.respond_to? :resource }

      client.hydra.run
      requests.flat_map { |req| req.response.resource }
    end

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

    def __entries__(path, **o)
      first_page = request(path, o.merge(ep: ep(per_page: 1, page: 1))).run
      total_entries = first_page.pagination.total_entries
      return [first_page] if total_entries <= 1 || @limit == 1

      unless @limit.nil?
        total_entries = @limit if total_entries > @limit
      end
      pages = total_entries / Client::MAX_ENTRIES_PER_PAGE
      pages += 1 if (total_entries % Client::MAX_ENTRIES_PER_PAGE).positive?
      pages.times.map do |page|
        per_page = Client::MAX_ENTRIES_PER_PAGE
        if !@limit.nil? && (pages == (page + 1)) && (total_entries % per_page != 0)
          per_page = total_entries % per_page
        end
        request(path, o.merge(ep: ep(per_page: per_page, page: page + 1))).tap do |req|
          client.hydra.queue req
        end
      end
    end
  end
end
