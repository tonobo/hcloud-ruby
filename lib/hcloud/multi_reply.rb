# frozen_string_literal: true

module Hcloud
  class MultiReply
    include Enumerable
    attr_accessor :cb

    def initialize(j:, pagination: nil)
      @j = j
      @pagination = pagination
    end

    def pagination
      @pagination || Pagination.new(@j.first.to_h['meta'].to_h['pagination'], nil, nil)
    end

    def each
      @cb.call(@j).each do |member|
        yield(member)
      end
    end
  end
end
