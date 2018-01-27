autoload :Typhoeus, "typhoeus"
autoload :Oj, "oj"

module Hcloud
  class Client
    attr_reader :token
    def initialize(token:)
      @token = token
    end

    def authorized?
      request("server_types").run
      true
    rescue Error::Unauthorized
      false
    end

    def request(path, **options)
      r = Typhoeus::Request.new(
        "https://api.hetzner.cloud/v1/#{path}",
        {
          headers: { 
            "Authorization" => "Bearer #{token}"
          },
        }.merge(options)
      )
      r.on_complete do |response|
        case response.code
        when 401
          raise Error::Unauthorized
        when 0
          raise Error::ServerError
        when 400...600
          j = Oj.load(response.body)
          code = j.dig("error", "code")
          error_class = case code
                        when "invalid_input" then Error::InvalidInput
                        when "forbidden" then Error::Forbidden
                        when "locked" then Error::Locked
                        when "not_found" then Error::NotFound
                        when "rate_limit_exceeded" then Error::RateLimitExceeded
                        when "resource_unavailable" then Error::ResourceUnavilable
                        when "service_error" then Error::ServiceError
                        when "uniqueness_error" then Error::UniquenessError
                        else
                          Error::ServerError
                        end
          raise error_class, j.dig("error", "message")
        end
      end
      r
    end
  end
end
