module Hcloud
  class MultiReply
    include Enumerable
    attr_accessor :cb

    def initialize(j:, pagination: nil)
       @j = j
       @pagination = pagination
    end

    def pagination
      @pagination || Pagination.new(@j.to_h["meta"].to_h["pagination"], nil, nil)
    end

    def each(&block)
      @cb.call(@j).each do |member|
        block.call(member)
      end
    end

  end
end
