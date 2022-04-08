# frozen_string_literal: true

require 'grape'

module Hcloud
  module FakeService
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def self.pagination_wrapper(object, key, per_page, page)
      o = object.deep_dup
      per_page ||= 25
      page ||= 1
      per_page = 50 if per_page > 50
      per_page = 25 if per_page < 1
      page = 1 if page < 1
      low = per_page * (page - 1)
      high = per_page * page
      last_page = (o[key].size / per_page) + ((o[key].size % per_page).zero? ? 0 : 1)
      o['meta'] ||= {}
      o['meta']['pagination'] = {
        'page' => page,
        'per_page' => per_page,
        'previous_page' => page > 1 ? page - 1 : nil,
        'next_page' => page < last_page ? page + 1 : nil,
        'last_page' => last_page,
        'total_entries' => o[key].size
      }
      o[key] = o[key][low...high].to_a
      o
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    class Base < Grape::API
      version 'v1', using: :path

      format :json

      before do
        next if headers['Authorization'] == 'Bearer secure'

        error!('Unauthorized', 401)
      end

      require_relative './action'
      require_relative './server'
      require_relative './image'
      require_relative './iso'
      require_relative './server_type'
      require_relative './floating_ip'
      require_relative './ssh_key'
      require_relative './location'
      require_relative './datacenter'
      require_relative './volume'

      mount Action
      mount Server
      mount Image
      mount ISO
      mount ServerType
      mount FloatingIP
      mount Datacenter
      mount Location
      mount SSHKey
      mount Volume
    end
  end
end
