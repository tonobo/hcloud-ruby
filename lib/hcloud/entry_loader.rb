require 'active_support/concern'
module Hcloud
  module EntryLoader
    extend ActiveSupport::Concern

    included do |klass|
      klass.const_get(:Attributes).each do |attribute, value|
        klass.send(:attr_accessor, attribute)
      end
    end

    def initialize(resource)
      self.class.const_get(:Attributes).each do |attribute, value|
        case value
        when nil
          self.send("#{attribute}=", resource[attribute.to_s])
        when :time
          self.send("#{attribute}=", Time.parse(resource[attribute.to_s]))
        else 
          if value.is_a?(Class) and value.include?(EntryLoader)
            self.send("#{attribute}=", value.new(resource[attribute.to_s]))
          end
        end
      end
    end
  end
end
