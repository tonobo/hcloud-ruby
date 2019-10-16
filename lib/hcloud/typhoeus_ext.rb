# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module Hcloud
  module TyphoeusExt
    Context = Struct.new(:client)

    ATTRIBUTES = %i[
      block autoload_action resource_path
      resource_class expected_code
    ].freeze

    attr_accessor(*ATTRIBUTES)

    def self.collect_attributes(kwargs)
      hash = {}
      ATTRIBUTES.each do |key|
        hash[key] = kwargs.delete(key) if kwargs.key?(key)
      end
      hash
    end

    def attributes=(kwargs)
      kwargs.each do |key, value|
        public_send("#{key}=", value)
      end
    end

    def parsed_json
      return {} if code == 204

      @parsed_json ||= Oj.load(body, symbol_keys: true)
    rescue StandardError
      raise Error::UnexpectedError, "unable to load body: #{body}"
    end

    def context
      @context ||= Context.new
    end

    def check_for_error(expected_code:)
      case code
      when 401 then raise(Error::Unauthorized)
      when 0 then raise(Error::ServerError, "Connection error: #{return_code}")
      when 400...600
        raise _error_class(error_code), error_message
      end

      raise Error::UnexpectedError, body if expected_code && expected_code != code
    end

    def pagination
      @pagination ||= Pagination.new(parsed_json[:meta].to_h[:pagination])
    end

    def resource_attributes
      _resource = [@resource_path].flatten.compact.map(&:to_s).map(&:to_sym)
      return parsed_json if _resource.empty?

      parsed_json.dig(*_resource)
    end

    def [](arg)
      parsed_json[arg]
    end

    def resource
      action = parsed_json[:action] if autoload_action
      return [Action.new(self, action), block.call(self)].flatten(1) if block && action
      return block.call(self) if block

      @resource_class.from_response(self, autoload_action: autoload_action)
    end

    def error_code
      error[:code]
    end

    def error_message
      error[:message]
    end

    def error
      parsed_json[:error].to_h
    end

    def _error_class(code)
      case code
      when 'invalid_input' then Error::InvalidInput
      when 'forbidden' then Error::Forbidden
      when 'locked' then Error::Locked
      when 'not_found' then Error::NotFound
      when 'rate_limit_exceeded' then Error::RateLimitExceeded
      when 'resource_unavailable' then Error::ResourceUnavailable
      when 'service_error' then Error::ServiceError
      when 'uniqueness_error' then Error::UniquenessError
      else
        Error::ServerError
      end
    end
  end
end
