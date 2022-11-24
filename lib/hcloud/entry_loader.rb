# frozen_string_literal: true

require 'active_support/concern'
require 'active_model'

module Hcloud
  module EntryLoader # rubocop:disable Metrics/ModuleLength
    extend ActiveSupport::Concern

    module Collection
      attr_accessor :response
    end

    included do |klass|
      klass.send(:attr_writer, :client)
      klass.include(ActiveModel::Dirty)
    end

    class_methods do # rubocop:disable Metrics/BlockLength
      attr_accessor :resource_url

      def _callbacks
        @_callbacks ||= { before: [], after: [] }
      end

      %i[before after].each do |method|
        define_method(method) { |&block| _callbacks[method] << block }
      end

      def schema(**kwargs)
        @schema ||= {}.with_indifferent_access
        return @schema if kwargs.empty?

        @schema.merge!(kwargs)
      end

      def updatable(*args)
        define_attribute_methods(*args)
        args.each do |updateable_attribute|
          define_method(updateable_attribute) { _attributes[updateable_attribute] }
          define_method("#{updateable_attribute}=") do |value|
            if _attributes[updateable_attribute] != value
              public_send("#{updateable_attribute}_will_change!")
            end
            _update_attribute(updateable_attribute, value)
          end
        end
      end

      def destructible
        define_method(:destroy) { prepare_request(method: :delete) }
      end

      def protectable(*args)
        define_method(:change_protection) do |**kwargs|
          kwargs.each_key do |key|
            next if args.map(&:to_s).include? key.to_s

            raise ArgumentError, "#{key} not an allowed protection mode (allowed: #{args})"
          end
          prepare_request('actions/change_protection', j: kwargs)
        end
      end

      def has_actions # rubocop:disable Naming/PredicateName
        define_method(:actions) do
          ActionResource.new(client: client, base_path: resource_url)
        end
      end

      def resource_class
        ancestors.reverse.find { |const| const.include?(Hcloud::EntryLoader) }
      end

      def from_response(response, autoload_action: nil)
        attributes = response.resource_attributes

        action_resp = _try_load_action(response) if autoload_action
        return action_resp unless attributes || action_resp.nil?

        client = response.context.client
        if attributes.is_a?(Array)
          results = attributes.map do |item|
            new(client, item).tap do |entity|
              entity.response = response
            end
          end
          results.tap { |ary| ary.extend(Collection) }.response = response
          return results
        end

        if action_resp.nil?
          return new(client, attributes).tap { |entity| entity.response = response }
        end

        [
          action_resp,
          new(client, attributes).tap { |entity| entity.response = response }
        ]
      end

      def _try_load_action(response)
        # some API endpoints return a list of actions (e.g. firewall action
        # apply_to_resources), some a single action (e.g. server action
        # attach_iso)
        actions = response.parsed_json[:actions]
        action = response.parsed_json[:action]

        client = response.context.client

        if actions
          return actions.map do |act|
            Action.new(client, act)
          end
        elsif action
          return Action.new(client, action)
        end

        nil
      end
    end

    attr_accessor :response

    def initialize(client = nil, resource = {})
      @client = client
      _load(resource)
    end

    def inspect
      "#<#{self.class.name}:0x#{__id__.to_s(16)} #{_attributes.inspect}>"
    end

    def client
      @client || response&.context&.client
    end

    def resource_url
      if block = self.class.resource_url
        return instance_exec(&block)
      end

      [self.class.resource_class.name.demodulize.tableize, id].compact.join('/')
    end

    def resource_path
      self.class.resource_class.name.demodulize.underscore
    end

    def prepare_request(url_suffix = nil, **kwargs, &block)
      kwargs[:resource_path] ||= resource_path
      kwargs[:resource_class] ||= self.class
      kwargs[:autoload_action] = true unless kwargs.key?(:autoload_action)

      client.prepare_request(
        [resource_url, url_suffix].compact.join('/'),
        **kwargs,
        &block
      )
    end

    def _attributes
      @_attributes ||= {}.with_indifferent_access
    end

    def method_missing(method, *args, &block)
      _attributes.key?(method) ? _attributes[method] : super
    end

    def respond_to_missing?(method, *args, &block)
      _attributes.key?(method) || super
    end

    def update(**kwargs)
      context = self
      _run_callbacks(:before)
      prepare_request(j: kwargs, method: :put) do |response|
        response.resource_class.from_response(
          response,
          autoload_action: response.autoload_action
        ).tap do |*_args|
          _run_callbacks(:after)
          context.send(:changes_applied)
        end
      end
    end

    def save
      update(changes.map { |key, _value| [key.to_sym, _attributes[key]] }.to_h)
    end

    def rollback
      restore_attributes
    end

    def _run_callbacks(order)
      self.class._callbacks[order].each { |block| instance_exec(&block) }
    end

    def _update_attribute(key, value)
      _attributes[key] = value
      instance_variable_set("@#{key}", value)
    end

    # rubocop: disable  Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/AbcSize
    def _load(resource)
      return if resource.nil?

      @_attributes = {}.with_indifferent_access

      resource.each do |key, value|
        definition = self.class.schema[key]

        if definition == :time
          _update_attribute(key, value ? Time.parse(value) : nil)
          next
        end

        if definition.is_a?(Class) && definition.include?(EntryLoader)
          _update_attribute(key, value ? definition.new(client, value) : nil)
          next
        end

        # if schema definition is [Class]
        if definition.is_a?(Array) && definition.first.include?(EntryLoader)

          # just set attribute to an empty array if value is no array or empty
          if !value.is_a?(Array) || value.empty?
            _update_attribute(key, [])
            next
          end

          if value.first.is_a?(Integer)
            # If value is an integer, this is the id of an object which's class can be
            # retreived from definition. Load a future object that can on access retreive the
            # data from the api and convert it to a proper object.
            _update_attribute(key, value.map { |id| Future.new(client, definition.first, id) })
          else
            # Otherwise the value *is* the content of the object
            _update_attribute(key, value.map { |item| definition.first.new(client, item) })
          end
          next
        end

        _update_attribute(key, value.is_a?(Hash) ? value.with_indifferent_access : value)
      end
    end
    # rubocop: enable  Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/AbcSize
  end
end
