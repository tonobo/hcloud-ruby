# frozen_string_literal: true

autoload :Typhoeus, 'typhoeus'
autoload :Oj, 'oj'

require 'delegate'

module Hcloud
  class Client
    MAX_ENTRIES_PER_PAGE = 50

    class << self
      attr_writer :connection

      def connection
        return @connection if @connection.is_a? Hcloud::Client

        raise ArgumentError, "client not correctly initialized, actually #{@client.inspect}"
      end
    end

    attr_reader :token, :auto_pagination, :hydra, :user_agent

    def initialize(token:, auto_pagination: false, concurrency: 20, user_agent: nil)
      @token = token
      @user_agent = user_agent || "hcloud-ruby v#{VERSION}"
      @auto_pagination = auto_pagination
      @concurrency = concurrency
      @hydra = Typhoeus::Hydra.new(max_concurrency: concurrency)
    end

    def concurrent
      @concurrent = true
      ret = yield
      ret.each do |element|
        next unless element.is_a?(AbstractResource)

        element.run
      end
      hydra.run
      ret
    ensure
      @concurrent = nil
    end

    def concurrent?
      !@concurrent.nil?
    end

    def authorized?
      request('server_types').run
      true
    rescue Error::Unauthorized
      false
    end

    def servers
      ServerResource.new(client: self)
    end

    def actions
      ActionResource.new(client: self)
    end

    def isos
      IsoResource.new(client: self)
    end

    def images
      ImageResource.new(client: self)
    end

    def datacenters
      DatacenterResource.new(client: self)
    end

    def locations
      LocationResource.new(client: self)
    end

    def server_types
      ServerTypeResource.new(client: self)
    end

    def ssh_keys
      SSHKeyResource.new(client: self)
    end

    def floating_ips
      FloatingIPResource.new(client: self)
    end

    def networks
      NetworkResource.new(client: self)
    end

    def volumes
      VolumeResource.new(client: self)
    end

    class ResourceFuture < Delegator
      def initialize(request) # rubocop:disable Lint/MissingSuper
        @request = request
      end

      def __getobj__
        @__getobj__ ||= @request&.response&.resource
      end
    end

    def prepare_request(url, args = {}, &block)
      req = request(url, **args.merge(block:))
      return req.run.resource unless concurrent?

      hydra.queue req
      ResourceFuture.new(req)
    end

    def request(path, options = {}) # rubocop:disable Metrics/MethodLength
      hcloud_attributes = TyphoeusExt.collect_attributes(options)
      if x = options.delete(:j)
        options[:body] = Oj.dump(x, mode: :compat)
        options[:method] ||= :post
      end
      q = []
      q << options.delete(:ep).to_s
      if x = options.delete(:q)
        q << x.to_param
      end
      path = path.dup
      path << "?#{q.join('&')}"
      r = Typhoeus::Request.new(
        "https://api.hetzner.cloud/v1/#{path}",
        {
          headers: {
            'Authorization' => "Bearer #{token}",
            'User-Agent' => user_agent,
            'Content-Type' => 'application/json'
          }
        }.merge(options)
      )
      r.on_complete do |response|
        response.extend(TyphoeusExt)
        response.attributes = hcloud_attributes
        response.context.client = self
        response.check_for_error unless response.request.hydra
      end
      r
    end
  end
end
