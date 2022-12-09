# frozen_string_literal: true

require 'typhoeus'

module Typhoeus
  module ExpectationExt
    def times_called
      @response_counter
    end
  end
end

Typhoeus::Expectation.include(Typhoeus::ExpectationExt)
