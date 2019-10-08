# frozen_string_literal: true

require 'active_support/concern'
module Hcloud
  module EntryLoader
    extend ActiveSupport::Concern

    module Collection
      attr_accessor :response
    end

    included do |klass|
      klass.send(:attr_writer, :client)
    end

    class_methods do
      attr_accessor :resource_url

      def schema(**kwargs)
        @schema ||= {}.with_indifferent_access
        return @schema if kwargs.empty?

        @schema.merge!(kwargs)
      end

      def from_response(response, autoload_action: nil)
        attributes = response.resource_attributes
        action = response.parsed_json[:action] if autoload_action
        client = response.context.client
        if attributes.is_a?(Array)
          results = attributes.map { |item| new(item).tap { |entity| entity.response = response } }
          results.tap { |ary| ary.extend(Collection) }.response = response
          return results
        end

        return Action.new(client, action) if attributes.nil? && action
        return new(attributes).tap { |entity| entity.response = response } if action.nil?

        [
          Action.new(client, action),
          new(attributes).tap { |entity| entity.response = response }
        ]
      end
    end

    attr_accessor :response

    def initialize(client = nil, **kwargs)
      @client = client
      _load(kwargs)
    end

    def inspect
      "#<#{self.class.name}:0x#{__id__.to_s(16)} #{attributes.inspect}>"
    end

    def client
      @client || response&.context&.client
    end

    def resource_url
      if block = self.class.resource_url
        return instance_exec(&block)
      end

      [self.class.name.demodulize.tableize, id].compact.join('/')
    end

    def resource_path
      self.class.name.demodulize.underscore
    end

    def prepare_request(url_suffix = nil, **kwargs, &block)
      kwargs[:resource_path] ||= resource_path
      kwargs[:resource] ||= self.class
      kwargs[:autoload_action] = true unless kwargs.key?(:autoload_action)

      client.prepare_request(
        [resource_url, url_suffix].compact.join('/'),
        **kwargs,
        &block
      )
    end

    def attributes
      @attributes ||= {}.with_indifferent_access
    end

    def method_missing(method, *args, &block)
      attributes.key?(method) ? attributes[method] : super
    end

    def respond_to_missing?(method, *args, &block)
      attributes.key?(method) || super
    end

    def _load(resource)
      @attributes = {}.with_indifferent_access

      resource.each do |key, value|
        definition = self.class.schema[key]

        if definition == :time
          attributes[key] = value ? Time.parse(value) : nil
          next
        end

        if definition.is_a?(Class) && definition.include?(EntryLoader)
          attributes[key] = value ? definition.new(client, value) : nil
          next
        end

        attributes[key] = value.is_a?(Hash) ? value.with_indifferent_access : value
      end
    end
  end
end
