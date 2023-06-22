# frozen_string_literal: true

require 'active_support/core_ext/string/inflections'

module Hcloud
  class Future < Delegator
    attr_reader :raw_data

    # rubocop: disable Lint/MissingSuper
    def initialize(client, target_class, id, raw_data: nil)
      @target_class = target_class
      @id = id
      @raw_data = raw_data
      @__client = client
    end
    # rubocop: enable Lint/MissingSuper

    def __getobj__
      # pluralize class name and convert it to symbol
      @__getobj__ ||= @__client.public_send(
        @target_class.name # full name of the class including namespaces
                     .demodulize # last module name only
                     .tableize # convert to table name, split words by _ + downcase
                     .pluralize
                     .to_sym
      ).find(@id)
    end
  end
end
