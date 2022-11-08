# frozen_string_literal: true

module Hcloud
  class Error < StandardError
    class Unauthorized < Error; end
    class ServerError < Error; end
    class Forbidden < Error; end
    class InvalidInput < Error; end
    class Locked < Error; end
    class NotFound < Error; end
    class RateLimitExceeded < Error; end
    class ResourceUnavailable < Error; end
    class ServiceError < Error; end
    class UniquenessError < Error; end
    class UnknownError < Error; end
    class UnexpectedError < Error; end
    class ResourcePathError < Error; end
  end
end
