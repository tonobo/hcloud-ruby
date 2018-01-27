require 'active_support/concern'
module Hcloud
  module EntryLoader
    extend ActiveSupport::Concern

    included do |klass|
      klass.send(:attr_reader, :parent, :client)
      klass.const_get(:Attributes).each do |attribute, value|
        klass.send(:attr_accessor, attribute)
      end
    end

    def initialize(resource, parent, client)
      @parent = parent
      @client = client
      self.class.const_get(:Attributes).each do |attribute, value|
        case value
        when nil
          self.send("#{attribute}=", resource[attribute.to_s])
        when :time
          unless resource[attribute.to_s].nil?
            self.send("#{attribute}=", Time.parse(resource[attribute.to_s]))
          end
        else 
          if value.is_a?(Class) and value.include?(EntryLoader)
            self.send("#{attribute}=", value.new(resource[attribute.to_s], self, client))
          end
        end
      end
    end

    def request(*args)
      client.request(*args)
    end
  end
end
