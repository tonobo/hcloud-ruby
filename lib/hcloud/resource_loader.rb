# frozen_string_literal: true

require 'time'

module Hcloud
  class ResourceLoader
    def initialize(schema, client:)
      @schema = schema
      @client = client
    end

    def load(data)
      load_with_schema(@schema, data)
    end

    private

    def load_with_schema(schema, data)
      if schema.respond_to?(:call)
        schema.call(data, @client)
      elsif schema.is_a?(Array) && schema.count.positive? && data.is_a?(Array)
        load_array(schema, data)
      elsif schema.is_a?(Hash) && data.is_a?(Hash)
        load_hash(schema, data)
      else
        load_single_item(schema, data)
      end
    end

    def load_array(schema, data)
      data.map do |item|
        load_with_schema(schema[0], item)
      end
    end

    def load_hash(schema, data)
      data.map do |key, value|
        [key, load_with_schema(schema[key], value)]
      end.to_h
    end

    def load_single_item(definition, value)
      if definition == :time
        return value ? Time.parse(value) : nil
      end

      if definition.is_a?(Class) && definition.include?(EntryLoader)
        return if value.nil?

        # If value is an integer, this is the id of an object which's class can be
        # retreived from definition. Load a future object that can on access retreive the
        # data from the api and convert it to a proper object.
        return Future.new(@client, definition, value) if value.is_a?(Integer)

        # Otherwise the value *is* the content of the object
        return definition.new(@client, value)
      end

      value
    end
  end
end
