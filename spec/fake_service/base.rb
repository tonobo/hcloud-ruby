require 'grape'

module Hcloud
  module FakeService
    class Base < Grape::API
      version "v1", using: :path

      format :json

      before do
        next if headers['Authorization'] == "Bearer secure"
        error!('Unauthorized', 401)
      end

      require_relative './action'
      require_relative './server'
      require_relative './image'
      require_relative './server_type'
      require_relative './ssh_key'
      require_relative './location'
      require_relative './datacenter'

      mount Action
      mount Server
      mount Image
      mount ServerType
      mount Datacenter
      mount Location
      mount SSHKey
    end
  end
end



